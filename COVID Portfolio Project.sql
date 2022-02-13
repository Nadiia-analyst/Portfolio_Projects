
--Select Data that we are going to be using

SELECT *
 FROM PortfolioProject.dbo.CovidDeaths
 ORDER BY 3, 4


SELECT *
 FROM PortfolioProject.dbo.CovidVaccinations
 ORDER BY 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2 


--Looking at Total Cases vs. Total Deaths to see the rate of people who had been infected by the virus also died from it.
--Shows the likelihood of dying if you contract COVID in a certain country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location like '%states'
and continent is not null
ORDER BY 1, 2 

-- Looking at Total Cases vs. Population
-- Shows what percentage of population that has gotten Covid

SELECT Location, date, total_cases, Population, (total_cases/population)*100 as PopulationPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location like '%states'
ORDER BY 1, 2 

SELECT Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2 


--Looking at countries with Highest Infection Rate compared to Population 

SELECT Location, Population, MAX(total_cases) as HighestInfectionRate,  MAX((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location
ORDER BY TotalDeathCount desc

SELECT *
 FROM PortfolioProject.dbo.CovidDeaths
 WHERE continent is not null
 ORDER BY 3, 4

 --To break things by LOCATION with its total death count

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

--Let's break things down by CONTINENT
--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Last syntax does not include for example Canada for North America in TotalDeathCount, therefore, instead "continent is not null" we put "continent is null"

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

--Global Numbers

SELECT SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like '%states'
WHERE continent is not null
--GROUP BY date 
ORDER BY 1, 2 


--Working with CovidVaccinations table and CovidDeaths (joining 2 tables)
--Where we rename the tables, for example, CovidDeaths as "dea", and CovidVaccinations as "vac"
--We will be joining 2 tables on location and date

SELECT *
FROM PortfolioProject..CovidDeaths as dea 
JOIN PortfolioProject..CovidVaccinations as vac
    ON dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location)
FROM PortfolioProject..CovidDeaths as dea 
JOIN PortfolioProject..CovidVaccinations as vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--Or,

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location)
FROM PortfolioProject..CovidDeaths as dea 
JOIN PortfolioProject..CovidVaccinations as vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--"Partition by" function is used to prevent SUM function from continuously running, instead it will stop when the location changes.
-- The sum value now has exceeded 2,147,483,647. So instead of converting it to "int", you we need to convert it to "bigint".

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as dea 
JOIN PortfolioProject..CovidVaccinations as vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--Now, finally looking at Total Population vs Vaccination
--However, we can't just run syntax (RollingPeopleVaccinated/population)*100,for that we need to use CTE


With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as dea 
JOIN PortfolioProject..CovidVaccinations as vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



--TEMP TABLE

DROP TABLE #PercentPopulationVaccinated2
CREATE TABLE #PercentPopulationVaccinated2
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO  #PercentPopulationVaccinated2
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea 
JOIN PortfolioProject..CovidVaccinations as vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date


SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated2



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
ORDER BY dea.location, dea.date
FROM PortfolioProject..CovidDeaths as dea 
JOIN PortfolioProject..CovidVaccinations as vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

Select *
FROM PercentPopulationVaccinated
