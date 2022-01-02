-- Select rows from a Table or View '[TableOrViewName]' in schema '[dbo]'
SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER by 3,4

-- Data Selection
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER by 1,2

--Alter Data type

Alter table PortfolioProject..CovidDeaths alter column total_deaths float
Alter table PortfolioProject..CovidDeaths alter column total_cases float 


-- Total Cases vs Total Deaths (Likelihood of dying if you contract covid in your country)

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%united kingdom'
AND continent IS NOT NULL
ORDER by 1,2

-- Total Cases vs Population (Percentage of the popoulation that got covid)

SELECT Location, date, population,  total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%united kingdom'
AND continent IS NOT NULL
ORDER by 1,2 

-- Countries with Highest Infection rate vs Population

SELECT Location, population,  MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%united kingdom'
WHERE continent IS NOT NULL
GROUP by Location, population
ORDER by PercentPopulationInfected DESC

-- Countries with Highest Death Count Per Population

SELECT Location,  MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP by Location
ORDER by TotalDeathCount DESC


-- Continent with Highest Death Count Per Population

SELECT continent,  MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP by continent
ORDER by TotalDeathCount DESC


-- World Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths,
            SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%united kingdom'
WHERE continent IS NOT NULL
--GROUP by date
ORDER by 1,2


-- Total Population vs Vaccinations

SELECT death.date, death.continent, death.location, death.population, vacs.new_vaccinations
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccination vacs
    ON death.location = vacs.location
    AND death.date = vacs.date
WHERE death.continent IS NOT NULL
ORDER by 3,1



--  Rolling numbers of vaccinated people
WITH PopvsVac  (continent, location, date, population, new_vaccinations, RollingVaccinatedPeople)
AS
(
SELECT death.date, death.continent, death.location, death.population, vacs.new_vaccinations
, SUM(CONVERT(FLOAT, vacs.new_vaccinations)) 
OVER (Partition by death.location ORDER BY death.location, death.date) as RollingVaccinatedPeople
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccination vacs
    ON death.location = vacs.location
    AND death.date = vacs.date
WHERE death.continent IS NOT NULL
-- ORDER by 3,1
)
SELECT * , (RollingVaccinatedPeople/Population)*100 AS PercentageRollingVacs
FROM PopvsVac 


-- View for visualization

CREATE VIEW PercentPopulationVaccinated AS
WITH PopvsVac  (continent, location, date, population, new_vaccinations, RollingVaccinatedPeople)
AS
(
SELECT death.date, death.continent, death.location, death.population, vacs.new_vaccinations
, SUM(CONVERT(FLOAT, vacs.new_vaccinations)) 
OVER (Partition by death.location ORDER BY death.location, death.date) as RollingVaccinatedPeople
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccination vacs
    ON death.location = vacs.location
    AND death.date = vacs.date
WHERE death.continent IS NOT NULL
-- ORDER by 3,1
)
SELECT * , (RollingVaccinatedPeople/Population)*100 AS PercentageRollingVacs
FROM PopvsVac 