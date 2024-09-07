select *
from PortfolioProject..[Covid Deaths1]
where continent is not null
order by 3,4;

--select *
--from PortfolioProject..[COVID Vaccinations]
--order by 3,4;

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, Total_deaths, population
from PortfolioProject..[Covid Deaths1]
order by 1, 2;

--Altering column data type
alter table PortfolioProject..[Covid Deaths1] alter column Total_deaths float
alter table PortfolioProject..[Covid Deaths1] alter column total_cases float
alter table PortfolioProject..[Covid Deaths1] alter column new_cases float
alter table PortfolioProject..[Covid Deaths1] alter column new_deaths float

--Looking at Total Cases Vs Total Deaths
--Shows the likelihood of dying if you contracted covid in your country in 2020
Select Location, date, total_cases, Total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..[Covid Deaths1]
where location like '%states%'
order by 1, 2;



--Looking at Total cases vs Population (Canada)
--shows what percentage of the population had COVID
Select Location, date, total_cases, population, (total_cases/population)*100 as Casesperpopulationpercentage
from PortfolioProject..[Covid Deaths1]
where location like '%canada%'
order by 1, 2;

--Countries with the highest infection rate compared to population
Select Location,  population, MAX(total_cases) as highestinfectiouncount,  MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..[Covid Deaths1]
--where location like '%canada%'
group by location, population
order by PercentPopulationInfected DESC;

--Showing countries with Highest Death count per population
Select Location,   MAX(total_deaths) as totaldeathcount
from PortfolioProject..[Covid Deaths1]
--where location like '%canada%'
where continent is not null
group by location
order by totaldeathcount DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENT
Select location,   MAX(total_deaths) as totaldeathcount
from PortfolioProject..[Covid Deaths1]
--where location like '%canada%'
where continent is null
group by location
order by totaldeathcount DESC;

--Showing continents with the highest death count per population
Select location, MAX(total_deaths) as totaldeathcount, MAX((total_deaths/population)*100) as highest_deathcount_pop
from PortfolioProject..[Covid Deaths1]
--where location like '%canada%'
where continent is not null
group by location
order by totaldeathcount DESC;


--GLOBAL NUMBERS : For each day globally, this query will show new deaths and new cases.
Select SUM(new_cases) as global_new_cases, SUM(new_deaths) as global_new_deaths,  SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathPercentage --total_cases, Total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..[Covid Deaths1]
where continent is not null
--group by date
order by 1, 2;

--global number query (My personal addition) - The TOP 10 deadliest days of the COVID pandemic between 2020-2021
Select TOP(20) date, SUM(new_cases) as global_new_cases, SUM(new_deaths) as global_new_deaths,  SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathPercentage --total_cases, Total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..[Covid Deaths1]
where continent is not null
group by date
order by GlobalDeathPercentage DESC;

--global number query (My personal addition) - The TOP 10 deadliest days of the COVID pandemic between 2020-2021
Select TOP(20) date, SUM(new_cases) as global_new_cases, SUM(new_deaths) as global_new_deaths,  SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathPercentage --total_cases, Total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..[Covid Deaths1]
where continent is not null
group by date
order by global_new_deaths DESC;


--Looking at Total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (Partition By dea.location order by dea.location, dea.date) as Rolling_vaccinations
From PortfolioProject..[COVID Vaccinations] vac
Join PortfolioProject..[Covid Deaths1] dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

---USE CTE (Common Table Expression)

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date) as Rolling_vaccinations
From PortfolioProject..[COVID Vaccinations] vac
Join PortfolioProject..[Covid Deaths1] dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (Rolling_vaccinations/Population)*100
From PopVsVac