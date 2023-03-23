
/*
Covid 19 Data Exploratory analysis
We are going to be using skills like Joins, Temp Tables, Aggregate Functions, Creating Views, Creating and dropping tables, and Converting Data Types.
Let's do it.
*/



SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths in my country (Argentina)

SELECT location, date, total_cases, total_deaths,
	   ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL and location = 'Argentina'
ORDER BY 1,2

-- Total Cases vs Population

SELECT location, date, total_cases, population,
	   ROUND((total_cases/population)*100,2) AS InfectionRate
FROM CovidDeaths
WHERE location = 'Argentina'
ORDER BY 1,2

-- Countries with Highest Infection Rate

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
       MAX(ROUND((total_cases/population)*100,2)) AS InfectionRate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Countries with Highest Death Rate

SELECT location, population, MAX(CAST(total_cases AS int)) AS HighestInfectionCount, 
       MAX(ROUND((total_deaths/population)*100,3)) AS DeathRate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Deaths Count per continent

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC

-- Global Numbers

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths,
	   SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date


SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths,
	   SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL


-- Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
	   SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent  IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVac(Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
	   SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent  IS NOT NULL
)
SELECT *, (RollingVaccinationCount/Population)*100
From PopVsVac



-- Another way to show the same with a temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
	   SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent  IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for future visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
	   SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent  IS NOT NULL