USE[PortfolioProject1]
GO

SELECT * 
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 3, 4 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 1, 2



-- Looking at Total Cases vs Total Deaths 
-- Shows the likelihood of dying if you contract covid in your country



SELECT location, date, total_cases, total_deaths, (Total_deaths/total_cases) * 100  AS DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE LOCATION LIKE '%United States%' AND continent IS NOT NULL
ORDER BY 1, 2



-- Total cases vs population
-- Shows what percentage of population got COVID



SELECT location, date, total_cases, population, (total_cases/population) * 100  AS CasePerPopulation
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 1, 2



-- Looking at countries with Highest Infection Rate compared to population



SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)) * 100  AS PercentPopulationInfected
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



-- COUNTRIES with the Highest Death Count per Population



SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeaths
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeaths DESC

GO



-- CONTINENTS with the Highest Death Count per Population



SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeaths
FROM [dbo].[CovidDeaths]
WHERE continent IS NULL
GROUP BY continent
ORDER BY TotalDeaths DESC

GO



-- Global Death Count 



SELECT location , SUM(CAST(total_deaths AS int)) AS TotalDeaths
FROM [dbo].[CovidDeaths]
WHERE location = 'World'
GROUP BY location

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE continent is not null
--Group by date
ORDER BY 1, 2 



-- TABLE CovidVaccinations 



SELECT * FROM [dbo].[CovidVaccinations]



-- Looking at Total Population compare to Vaccinations



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) AS RollingTotalOfVaccinations, 
FROM [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3 
 


 -- USE Common Table Expression (CTE)  



WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingTotalOfVaccinations) 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingTotalOfVaccinations
FROM [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingTotalOfVaccinations/Population)*100 AS Percentage
FROM PopvsVac



-- TEMP TABLE 



DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingTotalOfVaccinations numeric) 
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingTotalOfVaccinations
FROM [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingTotalOfVaccinations/Population)*100 AS Percentage
FROM PercentPopulationVaccinated



-- Creating a view to store data for later visualizations



CREATE VIEW PercentagePopulationVaccinated 
AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingTotalOfVaccinations
FROM [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3