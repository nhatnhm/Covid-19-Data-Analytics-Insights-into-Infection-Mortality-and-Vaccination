-- Creating a View for Data Cleaning and Data Preparation for Visualization

-- View DeathByContinent
IF OBJECT_ID('DeathByContinent', 'V') IS NOT NULL
    DROP VIEW DeathByContinent;
GO

CREATE VIEW DeathByContinent AS
WITH ByContinentAndLocation AS
(
    SELECT 
        continent,
        location,
        MAX(total_deaths) AS total_deaths, 
        MAX(total_cases) AS total_case, 
        MAX(population) AS population,
        CAST(MAX(total_deaths) AS REAL) / CAST(MAX(total_cases) AS REAL) * 100 AS deaths_percent
    FROM PortfolioProject..CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY continent, location
)
SELECT 
    continent AS Continent,
    SUM(total_deaths) AS Total_deaths, 
    SUM(total_case) AS Total_case, 
    SUM(population) AS Population,
    CAST(SUM(total_deaths) AS REAL) / CAST(SUM(total_case) AS REAL) * 100 AS Deaths_percent	
FROM ByContinentAndLocation
GROUP BY continent
GO

-- View Global_Numbers
IF OBJECT_ID('Global_Numbers', 'V') IS NOT NULL
    DROP VIEW Global_Numbers;
GO

CREATE VIEW Global_Numbers AS
SELECT 
    MAX(total_deaths) AS Total_deaths, 
    MAX(total_cases) AS Total_case, 
    MAX(population) AS Population,
    CAST(MAX(total_cases) AS REAL) / CAST(MAX(population) AS REAL) * 100 AS Cases_percent,
    CAST(MAX(total_deaths) AS REAL) / CAST(MAX(total_cases) AS REAL) * 100 AS Deaths_percent
FROM PortfolioProject..CovidDeaths
WHERE location = 'World'
GO

-- View InfectionByLocation
IF OBJECT_ID('InfectionByLocation', 'V') IS NOT NULL
    DROP VIEW InfectionByLocation;
GO

CREATE VIEW InfectionByLocation AS
SELECT 
    continent,
    location AS Location,
    date,
    CASE
        WHEN population IS NULL THEN 0
        ELSE population
    END AS Population,
    CASE
        WHEN total_cases IS NULL THEN 0
        ELSE total_cases
    END AS HighestInfectionCount,
    CASE 
        WHEN total_cases IS NULL OR population IS NULL THEN 0
        ELSE CAST(total_cases AS REAL) / CAST(population AS REAL) * 100
    END AS PercentPopulationInfected,
    CASE
        WHEN total_cases IS NULL THEN 0
        ELSE SUM(total_cases) OVER (PARTITION BY date)
    END AS Global_Total_Cases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GO

-- View InfectionByContinent
IF OBJECT_ID('InfectionByContinent', 'V') IS NOT NULL
    DROP VIEW InfectionByContinent;
GO

CREATE VIEW InfectionByContinent AS
SELECT 
    continent,
    date,
    CASE
        WHEN total_deaths_continent IS NULL THEN 0
        ELSE total_deaths_continent
    END AS Total_Deaths_Continent,
    CASE 
        WHEN total_cases_continent IS NULL THEN 0
        ELSE total_cases_continent
    END AS Total_Cases_Continent,
    CASE
        WHEN death_percent IS NULL THEN 0
        ELSE death_percent
    END AS Death_Percent,
    CASE 
        WHEN HightEfecttion IS NULL THEN 0
        ELSE HightEfecttion
    END AS High_Infection
FROM
(
    SELECT DISTINCT
        C.continent,
        date,
        SUM(C.total_deaths) OVER (PARTITION BY C.continent ORDER BY date) AS total_deaths_continent,
        SUM(total_cases) OVER (PARTITION BY C.continent ORDER BY date) AS total_cases_continent,
        SUM(CAST(C.total_deaths AS REAL)) OVER (PARTITION BY C.continent ORDER BY date) / 
        SUM(total_cases) OVER (PARTITION BY C.continent ORDER BY date) AS death_percent,
        SUM(total_cases) OVER (PARTITION BY C.continent ORDER BY date) / 
        CAST(P.Population AS REAL) AS HightEfecttion
    FROM PortfolioProject..CovidDeaths AS C
    LEFT JOIN DeathByContinent AS P
    ON C.continent = P.Continent
    WHERE C.continent IS NOT NULL
) AS Null_InfectionByContinent;
GO

-- View PercentPopulationVaccinated
IF OBJECT_ID('PercentPopulationVaccinated', 'V') IS NOT NULL
    DROP VIEW PercentPopulationVaccinated;
GO

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    continent,
    location,
    date,
    population,
    new_vaccinations,
    CASE 
        WHEN rolling_vaccinations IS NULL THEN 0
        ELSE rolling_vaccinations
    END AS Rolling_Vaccinations,
    CASE 
        WHEN percent_vaccinated IS NULL THEN 0
        ELSE percent_vaccinated
    END AS Percent_Vaccinated
FROM
(
    SELECT 
        Death.continent,
        Death.location,
        Death.date,
        Death.population,
        CASE
            WHEN Vacc.new_vaccinations IS NULL THEN 0
            ELSE Vacc.new_vaccinations
        END AS new_vaccinations,
        SUM(Vacc.new_vaccinations) OVER (PARTITION BY Death.location ORDER BY Death.date) AS rolling_vaccinations,
        SUM(Vacc.new_vaccinations) OVER (PARTITION BY Death.location ORDER BY Death.date) / CAST(Death.population AS REAL) AS percent_vaccinated
    FROM PortfolioProject..CovidVaccinations AS Vacc
    INNER JOIN PortfolioProject..CovidDeaths AS Death
        ON Vacc.location = Death.location 
        AND Vacc.date = Death.date
    WHERE Vacc.continent IS NOT NULL
) AS Null_PercentPopulationVaccinated
order by location, date
GO
