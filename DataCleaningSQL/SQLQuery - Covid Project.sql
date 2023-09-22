Select * 
FROM PortfolioProject.. coviddeaths
Where continent is not null
order by 3,4

--Select * 
--FROM PortfolioProject.. covidvaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.. coviddeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths.
-- Shows likelihood of dying if you contract covid in any country

Select Location, date, total_cases, total_deaths, ROUND(((total_deaths/total_cases)*100),2) as DeathPercentage
From PortfolioProject.. coviddeaths
Where location like '%argentina'
order by 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid

Select Location, date, total_cases, population, ROUND(((total_cases/population)*100),2) as PercentPopulationInfected
From PortfolioProject.. coviddeaths
Where location like '%argentina'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject.. coviddeaths
--Where location like '%argentina'
group by Location, Population
order by PercentPopulationInfected DESC

-- Showing COuntries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.. coviddeaths
Where continent is not null
--Where location like '%argentina'
group by Location
order by TotalDeathCount DESC

-- Let's break things down by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.. coviddeaths
Where continent is null
--Where location like '%argentina'
group by location
order by TotalDeathCount DESC

-- or

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.. coviddeaths
Where continent is not null
--Where location like '%argentina'
group by continent
order by TotalDeathCount DESC


-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.. coviddeaths
Where continent is not null
--Where location like '%argentina'
group by continent
order by TotalDeathCount DESC

-- Global Numebers

Select date, sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
From PortfolioProject.. coviddeaths
Where continent is not null
group by date
order by 1,2


-- TOTAL WOLRWIDE

Select sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
From PortfolioProject.. coviddeaths
Where continent is not null
--group by date
order by 1,2



-- Looking at Total population vs vacciontations

with PopvsVac (continent, Location, Date, Population, New_Vaccionations, RollingPeopleVaccionated)
as
(
Select dea.continent, dea.location, dea.date, population, new_vaccinations,
SUM(CONVERT(int, new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date)
as RollingPeopleVaccionated
--,(RollingPeopleVaccionated/population)*100
FROM PortfolioProject.. covidvaccinations as dea
JOIN PortfolioProject.. coviddeaths as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccionated/population)*100
From PopvsVac 

-- Use cte

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 




