--select *
--from portfolioprojects..CovidDeaths
--order by 3,4

--select *
--from portfolioprojects..CovidVaccinations
--order by 3,4

--Selecting the data we need

select Location, date, total_cases, new_cases, total_deaths, population
from portfolioprojects..CovidDeaths
order by 1,2


-- Altering the columns datatype so that we can perform arithmetic operations
ALTER TABLE portfolioprojects..CovidDeaths
ALTER COLUMN total_cases float

ALTER TABLE portfolioprojects..CovidDeaths
ALTER COLUMN total_deaths float


-- Looking at the Total Cases VS Total Deaths
--Shows the likelyhood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioprojects..CovidDeaths
where location like '%India%'
order by 1,2



-- Looking at Total Cases V/S Population
-- Shows what percentage of Population got Covid

select Location, date, Population, total_cases, (total_cases/Population)*100 as CasePercentage
from portfolioprojects..CovidDeaths
where location like '%India%'
order by 1,2


-- Looking at Countries with highest Infection Rate compared to Population

select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population)*100) as InfectionRate
from portfolioprojects..CovidDeaths
-- where location like '%India%'
group by location, population
order by InfectionRate desc


-- Showing countries with highest deaths

select Location, MAX(total_deaths) as TotalDeathCount
from portfolioprojects..CovidDeaths
-- where location like '%India%'
where continent is not null
group by location
order by TotalDeathCount desc


-- LET'S break things by continent

select continent, MAX(total_deaths) as TotalDeathCount
from portfolioprojects..CovidDeaths
-- where location like '%India%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Exploration
-- excluding where new_cases are zero to avoid errors

--Per day data

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
as DeathPercentage
from portfolioprojects..CovidDeaths
where continent is not null and new_cases != 0
group by date
order by 1,2

-- Overall data

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
as DeathPercentage
from portfolioprojects..CovidDeaths
where continent is not null and new_cases != 0
--group by date
order by 1,2



-- Looking at Total Population V/S Vaccination
--Firstly sorting vaccinations per day per country

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint, vac.new_vaccinations)) OVER 
(partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From portfolioprojects..CovidDeaths dea
Join portfolioprojects..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null --and dea.location like '%India%'
order by 2,3



-- Using CTE to find population V/S vaccinations

With PopvsVac (Continent, Location, Date, Population, New_vaccinated, RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint, vac.new_vaccinations)) OVER 
(partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From portfolioprojects..CovidDeaths dea
Join portfolioprojects..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null --and dea.location like '%India%'
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
from PopvsVac


-- Using Temp Table

Drop Table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint, vac.new_vaccinations)) OVER 
(partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From portfolioprojects..CovidDeaths dea
Join portfolioprojects..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null --and dea.location like '%India%'
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
from #PercentagePopulationVaccinated


-- Creating View to store data for later visualizations 

-- View-1
create view PercentagePopulationVaccinated as
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint, vac.new_vaccinations)) OVER 
(partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From portfolioprojects..CovidDeaths dea
Join portfolioprojects..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null --and dea.location like '%India%'
--order by 2,3


-- VIEW-2
create view PercentagePopulationInfected as
select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population)*100) as InfectionRate
from portfolioprojects..CovidDeaths
-- where location like '%India%'
group by location, population
--order by InfectionRate desc


-- VIEW-3
create view PopulationDied as
select Location, MAX(total_deaths) as TotalDeathCount
from portfolioprojects..CovidDeaths
-- where location like '%India%'
where continent is not null
group by location
--order by TotalDeathCount desc
