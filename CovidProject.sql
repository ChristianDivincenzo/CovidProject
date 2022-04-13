SELECT *
FROM CovidDeaths
Order by 3,4;

# SELECT *
# FROM CovidVaccinations
# Order by 3,4

## Select Data that I will be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
Order by 1,2;

## Examining Total Cases vs Total Deaths
## Portrays percentage of deaths per total cases in the United States

SELECT Location, date, total_cases, total_deaths, format((total_deaths / total_cases * 100), 3) as FatalityPercentage
FROM CovidDeaths
Where location like '%states%'
Order by 1,2;

## Total cases vs Population
SELECT Location, date, Population, total_cases, format((total_cases / population * 100), 3) as PctOfPopulationInfected
FROM CovidDeaths
WHERE continent is not null
## Where location like '%states%'
Order by 1,2;


## Select countries with the Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as PeakInfectionCount, MAX((total_cases / population * 100))
as PercentPopulationInfected
FROM CovidDeaths
## Where location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected desc;

## Select countries with highest death rates per population
SELECT Location, MAX(CAST(CONV(total_deaths,16,10) AS UNSIGNED INTEGER)) as TotalDeathCount
FROM CovidDeaths
WHERE continent != ''
## Where location like '%states%'
Group by Location 
Order by TotalDeathCount desc;


## Breaking down by continent
SELECT continent, MAX(CAST(CONV(total_deaths,16,10) AS UNSIGNED INTEGER)) as TotalDeathCount
FROM CovidDeaths
##WHERE continent = '' and location not like '%income%'
WHERE continent is not null
Group by continent 
Order by TotalDeathCount desc;

## Global Numbers

SELECT date, SUM(CAST(CONV(new_cases,16,10) AS UNSIGNED INTEGER)) as total_cases, SUM(CAST(CONV(new_deaths,16,10) AS UNSIGNED INTEGER)) as total_deaths, SUM(CAST(CONV(new_deaths,16,10) AS UNSIGNED INTEGER)) /
SUM(CAST(CONV(new_cases,16,10) AS UNSIGNED INTEGER))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent != ''
Group by date
Order by 1,2;

## Looking at Total Population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(CONV(vac.new_vaccinations,16,10) AS UNSIGNED INTEGER)) OVER (Partition by dea.Location Order by dea.location,
    dea.Date) as RollingVaccinated
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	On dea.location = vac.location
    and dea.date = vac.date
   # WHERE dea.continent = 'Europe'
   WHERE dea.continent != ''
Order by 2,3;

## Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(CONV(vac.new_vaccinations,16,10) AS UNSIGNED INTEGER)) OVER (Partition by dea.Location Order by dea.location,
    dea.Date) as RollingVaccinated
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	On dea.location = vac.location
    and dea.date = vac.date
   # WHERE dea.continent = 'Europe'
   WHERE dea.continent != ''
##Order by 2,3
)
SELECT *, (RollingVaccinated / Population) * 100
FROM PopvsVac;


## Creating View to store data for visualizations

Create View PopvsVac as
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(CONV(vac.new_vaccinations,16,10) AS UNSIGNED INTEGER)) OVER (Partition by dea.Location Order by dea.location,
    dea.Date) as RollingVaccinated
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	On dea.location = vac.location
    and dea.date = vac.date
   # WHERE dea.continent = 'Europe'
   WHERE dea.continent != ''
   )
   SELECT *, (RollingVaccinated / Population) * 100
	FROM PopvsVac;


Select *
From PopvsVac





