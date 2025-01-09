-- Looking at Total Case vs Total Deaths
-- Shows likehood of dying if you contract covid in your country
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    CAST(total_deaths AS REAL) / CAST(total_cases AS REAL) * 100 AS deaths_percent
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    location LIKE '%States%';
GO

-- Looking at Total Case vs Population
-- Shows what percentage of population got Covid
SELECT 
    location,
    date,
    total_cases,
    population,
    CAST(total_cases AS REAL) / CAST(population AS REAL) * 100 AS cases_percent
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    location LIKE '%States%';
GO

-- Looking at Countries with Highest Infection Rate compare to Population
SELECT 
    location AS Location,
    MAX(population) AS Population,
    MAX(total_cases) AS HighestInfectionCount,
    CAST(MAX(total_cases) AS REAL) / CAST(MAX(population) AS REAL) * 100 AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    location 
ORDER BY 
    HighestInfectionCount DESC;
GO

-- Showing Countries with highest Deaths Count per Population
SELECT 
    location,
    MAX(total_deaths) AS total_deaths, 
    MAX(total_cases) AS total_case, 
    MAX(population) AS population,
    CAST(MAX(total_deaths) AS REAL) / CAST(MAX(total_cases) AS REAL) * 100 AS deaths_percent,
    CAST(MAX(total_cases) AS REAL) / CAST(MAX(population) AS REAL) * 100 AS infection_percent
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    location
ORDER BY 
    total_deaths DESC;
GO

-- Showing continents with the highest death cout per population
WITH ByContinentAndLocation (continent, location, total_deaths, total_case, population, deaths_percent) AS
(
    SELECT 
        continent,
        location,
        MAX(total_deaths) AS total_deaths, 
        MAX(total_cases) AS total_case, 
        MAX(population) AS population,
        CAST(MAX(total_deaths) AS REAL) / CAST(MAX(total_cases) AS REAL) * 100 AS deaths_percent
    FROM 
        PortfolioProject..CovidDeaths
    WHERE 
        continent IS NOT NULL
    GROUP BY 
        continent, location
)

SELECT 
    continent,
    SUM(total_deaths) AS total_deaths, 
    SUM(total_case) AS total_case, 
    SUM(population) AS population,
    CAST(SUM(total_deaths) AS REAL) / CAST(SUM(total_case) AS REAL) * 100 AS deaths_percent	
FROM 
    ByContinentAndLocation
GROUP BY 
    continent
ORDER BY 
    total_deaths DESC;
GO

-- Global Numbers
SELECT 
    MAX(total_deaths) AS total_deaths, 
    MAX(total_cases) AS total_case, 
    MAX(population) AS population,
    CAST(MAX(total_cases) AS REAL) / CAST(MAX(population) AS REAL) * 100 AS cases_percent,
    CAST(MAX(total_deaths) AS REAL) / CAST(MAX(total_cases) AS REAL) * 100 AS deaths_percent
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    location = 'World';
GO

-- Global Numbers by Date
SELECT 
    FORMAT(date, 'yyyy-MM') AS date,
    MAX(total_deaths) AS total_deaths, 
    MAX(total_cases) AS total_case, 
    MAX(population) AS population,
    CAST(MAX(total_cases) AS REAL) / CAST(MAX(population) AS REAL) * 100 AS cases_percent,
    CAST(MAX(total_deaths) AS REAL) / CAST(MAX(total_cases) AS REAL) * 100 AS deaths_percent
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    location = 'World'
GROUP BY 
    FORMAT(date, 'yyyy-MM');
GO

-- Looking at Total Population vs Vaccinations
WITH PopvsVac (continent, location, date, population, new_vaccinations, total_vaccinations) AS
(
    SELECT 
        Death.continent,
        Death.location,
        Death.date,
        Death.population,
        Vacc.new_vaccinations,
        SUM(Vacc.new_vaccinations) OVER (PARTITION BY Death.location ORDER BY Death.date) AS total_vaccinations
    FROM 
        PortfolioProject..CovidVaccinations AS Vacc
    INNER JOIN PortfolioProject..CovidDeaths AS Death
        ON Vacc.location = Death.location 
        AND Vacc.date = Death.date
    WHERE 
        Death.continent IS NOT NULL
)

SELECT 
    *,
    total_vaccinations / population * 100 AS Percent_Vacc
FROM 
    PopvsVac;
GO












