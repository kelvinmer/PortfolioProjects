Select *
From projects..CovidDeaths$
order by 3, 4

Select * 
From projects..COVID_VACCINES
order by 3,4 

Select Location, date, total_cases, new_cases,total_deaths,population
From projects..CovidDeaths$
order by 1,2

-- Looking at total cases vs total deaths 
-- shows likelihood of dying if contract covid 
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
From projects..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at total cases vs populations 
-- shows percentage got covid 
Select Location, date, total_cases,Population, (total_cases/population) *100 as CasesperPopulatio 
From projects..CovidDeaths$
Where location like '%states%'
order by 1,2

--What country has highest infection rate
Select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as CasesperPopulation
From projects..CovidDeaths$
--Where location like '%states%' 
Group by Location, Population
order by CasesperPopulation desc

-- Showing Country with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From projects..CovidDeaths$
--Where location like '%states%' 
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- breaking down continent 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From projects..CovidDeaths$
--Where location like '%states%' 
Where continent is null
Group by Location
order by TotalDeathCount desc

-- breaking down by continent 


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From projects..CovidDeaths$
--Where location like '%states%' 
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- global numbers

select date,SUM(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases) as deathpercentage  --total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from projects..CovidDeaths$
where continent is not null
group by date
order by 1,2

--remove date to give total cases, death and death percentage

select SUM(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases) as deathpercentage  --total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from projects..CovidDeaths$
where continent is not null
group by date
order by 1,2


-- looking at total populations vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population
From projects..CovidDeaths$ dea
Join projects..[COVID VACCINES] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2
---
Select dea.continent, dea.location, dea.date, dea.population, vac.newvaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
From projects..CovidDeaths$ dea
Join projects..[COVID VACCINES] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2
---
Select dea.continent, dea.location, dea.date, dea.population, vac.newvaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollimgPeopleVaccinated
-- rollingpeoplevaccinated/pop * 100
From projects..CovidDeaths$ dea
Join projects..[COVID VACCINES] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2

-- USE CTE

with PopsvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.newvaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollimgPeopleVaccinated
-- rollingpeoplevaccinated/pop * 100 run once done with popsvsVac
From projects..CovidDeaths$ dea
Join projects..[COVID VACCINES] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 1,2
)


-- temp table 
DROP Table if exists #PercentpopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
populatopn numeric,
new_vaccinations numeric,
rollingPeoplevaccinated numeric
)
insert into #percentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.newvaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollimgPeopleVaccinated
-- rollingpeoplevaccinated/pop * 100 run once done with popsvsVac
From projects..CovidDeaths$ dea
Join projects..[COVID VACCINES] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 1,2
)

-- create view for visualizations 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.newvaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollimgPeopleVaccinated
-- rollingpeoplevaccinated/pop * 100 run once done with popsvsVac
From projects..CovidDeaths$ dea
Join projects..[COVID VACCINES] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 1,2

