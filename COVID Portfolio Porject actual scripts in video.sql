
Select *
From PortfolioProject..CovidDeaths$
order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations$
--Order by 3,4

-- Select Data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking total cases vs total deaths
-- Shows likelihood of dying if contract covid in %states%
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%state%'
order by 1,2

-- Looking at total cases vs population
--Shows percentage of population got Covid

Select location, date, Population, total_cases, (total_cases/Population)*100 as CaseVsPopulationPercentage
From PortfolioProject..CovidDeaths
--Where location like '%state%'
order by 1,2

-- Show Countries with Highest Infection rate compared to Population
Select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as CaseVsPopulationPercentage
From PortfolioProject..CovidDeaths
--Where location like '%state%'
Group by location, Population
order by 4 desc

--Show countries with highest deathcount per population
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by location
order by 2 desc

-- Break things down by continent
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by continent
order by 2 desc

-- Show continent with highest death count as per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by continent
order by 2 desc

-- Global number
Select SUM(new_cases) as totalcases, SUM(new_deaths)as totaldeath, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where new_cases != 0
and continent is not null
--Group by date
order by 1,2


--looking at total populatiob vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.Date)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

Select *, ( RollingPeopleVaccinated/Population)*100 
From PopvsVac

--Temp Table

DROP Table if exists #PercentPopVac
Create Table #PercentPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vac numeric,
RollingPeopleVac numeric
)

Insert into #PercentPopVac
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollPeopleVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select 
	*, (RollingPeopleVac/Population)*100 as RollVsPoppulation
From #PercentPopVac

-- Cre8 view to store data for visualization later

USE PortfolioProject
GO
Create view PercentPopVac as
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollPeopleVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select * 
From PercentPopVac