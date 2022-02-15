--Queries used for Tableau Project

-- 1. Calculate COVID-19 total cases, total deaths and DeathPercentage

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null 
ORDER BY 1,2


-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--FROM PortfolioProject..CovidDeaths
----WHERE location like '%states%'
--WHERE location = 'World'
----GROUP BY date
--ORDER BY 1,2


-- 2. 

-- We take these out: 'World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low Income', as they are not included in the above queries and want to stay consistent
-- For example, European Union is a part of Europe

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null 
AND location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low Income')
GROUP BY location
ORDER BY TotalDeathCount desc


-- 3. Calculate percentage of population that got infected

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-- 4.

SELECT Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc

