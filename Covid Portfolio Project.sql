SELECT *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--SELECT *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by location,date

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you cintract covid in your country

Select location,date,total_cases,total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%india%'
and continent is not null
Order by 1,2

-- Looking at the total cases vs Population
-- shows what percentage of population got covid

Select location,date,population,total_cases, (cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Order by 1,2

--Countries with Highest Infection Rate compared to Population

Select location,population,MAX(total_cases) as HighestInfectionCount, MAX(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Group by location,population
Order by PercentPopulationInfected desc

--Showing the countries with Highest Death Count for Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null
Group by location,population
Order by TotalDeathCount desc

--Lets Break things down by continent



--Showing Continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations )) OVER  (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE

With PopvsVac( continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations )) OVER  (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated /population) * 100
From PopvsVac


--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations )) OVER  (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated /population) * 100
From #PercentPopulationVaccinated



-- Creating view to store data for later visualizations


Create View PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations )) OVER  (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated


