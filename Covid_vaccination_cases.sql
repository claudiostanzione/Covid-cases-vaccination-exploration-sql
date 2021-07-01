--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..['covid-deaths']
--ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases,  total_deaths ,((CONVERT(float,(total_deaths)))/(CONVERT(float, total_cases)))*100 AS deat
FROM PortfolioProject..['covid-deaths']
WHERE location LIKE '%states%'
ORDER BY 2 


--LOOKING AT TOTAL CASES VS POPULATION

SELECT location, date, total_cases,  population ,((CONVERT(float,(total_cases)))/(CONVERT(float, population)))*100 AS deat
FROM PortfolioProject..['covid-deaths']
--WHERE location LIKE '%states%'
ORDER BY 2 


-- COUNTRIES WITH HIGHEST RATES INFECTIONS COMPARED TO POPULATION
SELECT location, population ,MAX(total_cases) AS HIGHESTINFECTIONRATE, MAX((CONVERT(float,(total_cases)))/(CONVERT(float, population)))*100 AS percentpopulationinfected
FROM PortfolioProject..['covid-deaths']
GROUP BY location,population
ORDER BY percentpopulationinfected desc

-- SHOWING THE COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPOULATION
SELECT location, population ,MAX(cast(total_deaths as float)) AS totaldeathcount, MAX((CONVERT(float,(total_deaths)))/(CONVERT(float, population)))*100 AS percentpopulationdeaths
FROM PortfolioProject..['covid-deaths']
WHERE continent is not null 
GROUP BY location,population
ORDER BY totaldeathcount desc

-- with continents
SELECT location , MAX(cast(total_deaths as float)) AS totaldeathcount, MAX((CONVERT(float,(total_deaths)))/(CONVERT(float, population)))*100 AS percentpopulationdeaths
FROM PortfolioProject..['covid-deaths']
WHERE continent is  null 
GROUP BY location
ORDER BY totaldeathcount desc

-- showing continent with highest deat count per population
SELECT location ,MAX((CONVERT(float,(total_deaths)))/(CONVERT(float, population)))*100 AS percentpopulationdeaths
FROM PortfolioProject..['covid-deaths']
WHERE continent is  null 
GROUP BY location
ORDER BY percentpopulationdeaths desc

-- global numbers (most day ratio deaths/cases)
SELECT date,SUM(cast(new_cases as float)) as total_cases , SUM(cast(new_deaths as float)) as total_deaths  ,SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 AS  DEATHPERCENTAGE
FROM PortfolioProject..['covid-deaths']
WHERE continent is not null
GROUP BY date
ORDER BY 4 desc

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS
WITH POPVSVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..['covid-deaths'] dea
JOIN PortfolioProject..['covid-vaccinations'] vac
	ON dea.location = vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 
from POPVSVAC

ORDER BY 7 desc

-- Creating view to store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
