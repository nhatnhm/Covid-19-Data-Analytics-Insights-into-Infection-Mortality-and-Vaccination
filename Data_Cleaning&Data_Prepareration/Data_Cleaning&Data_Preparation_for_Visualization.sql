-- Creating a View for Data Cleaning and Data Preparation for Visualization

-- View InfectionAndDeathsByLocation
IF OBJECT_ID('InfectionAndDeathsByLocation', 'V') IS NOT NULL
    DROP VIEW InfectionAndDeathsByLocation;
GO

CREATE VIEW InfectionAndDeathsByLocation AS
SELECT 
    continent,
    location,
    date,
    CASE
        WHEN new_cases IS NULL THEN 0
        ELSE new_cases
    END AS new_cases,
    CASE 
        WHEN new_deaths IS NULL THEN 0
        ELSE new_deaths
    END AS new_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GO

-- View LocationPopulation
IF OBJECT_ID('LocationPopulation', 'V') IS NOT NULL
    DROP VIEW LocationPopulation;
GO

CREATE VIEW LocationPopulation AS
SELECT 
	DISTINCT
	location,
	population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GO

-- View VaccinationByLocation
IF OBJECT_ID('VaccinationByLocation', 'V') IS NOT NULL
    DROP VIEW VaccinationByLocation;
GO

CREATE VIEW VaccinationByLocation AS
SELECT 
    continent,
    location,
    date,
    CASE
        WHEN people_vaccinated IS NULL THEN 0
        ELSE people_vaccinated
    END AS people_vaccinated
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
GO

