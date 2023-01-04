select *
from Covid_Research..CovidDeaths$
order by 3,4

--select *
--from Covid_Research..CovidVaccinations$
--order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases,new_cases,total_deaths,population
from Covid_Research..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid_Research..CovidDeaths$
where location like '%India'
order by 1,2

--Looking at Total Cases vs Population
--Shows the percentage of people that got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
from Covid_Research..CovidDeaths$
where location like '%India'
order by 1,2

--Looking at Countries with highest infection rate compared to population
Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopInfected
from Covid_Research..CovidDeaths$
--where location like '%India'
Group by location, population
order by 4 desc

---Showing Countries with Highest Death Count Per Population
Select Location, Max(cast(total_deaths as int)) as TotalDeaths, Max((total_deaths/population))*100 as PercentPeopleDied
from Covid_Research..CovidDeaths$
--where location like '%India'
where continent is not null
Group by location
order by 2 desc

--Breaking down by continent
Select location, Max(cast(total_deaths as int)) as TotalDeaths, Max((total_deaths/population))
from Covid_Research..CovidDeaths$
--where location like '%India'
where continent is null
Group by location
order by 2 desc

--Showing continents with highest death counts
--Breaking down by continent when continent is not null
Select continent, Max(cast(total_deaths as int)) as TotalDeaths
from Covid_Research..CovidDeaths$
--where location like '%India'
where continent is not null
Group by continent
order by 2 desc

--GLOBAL NUMBERS
Select  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Covid_Research..CovidDeaths$
where continent is not null
--group by date
order by 1,2


--Looking at Total Population Vs Vaccinations


Select *
from Covid_Research..CovidDeaths$ dea
Join Covid_Research..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date=vac.date

	 
	 
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
from Covid_Research..CovidDeaths$ dea
Join Covid_Research..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date=vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Research..CovidDeaths$ dea
Join Covid_Research..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE
With PopvsVac (Continent,Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Research..CovidDeaths$ dea
Join Covid_Research..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Research..CovidDeaths$ dea
Join Covid_Research..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to Store data for later visualisations

Create View PercentPopulationVaccinateds as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Research..CovidDeaths$ dea
Join Covid_Research..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *
From PercentPopulationVaccinated