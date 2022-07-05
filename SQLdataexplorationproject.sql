Select *
From portfolioproject..CovidDeaths
order by 3,4

Select *
From portfolioproject..CovidVaccinations
order by 3,4

--Select the data we are using 
Select location, date, total_cases, new_cases, total_deaths, population
From portfolioproject..CovidDeaths 
order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, (total_deaths/total_cases)*100 as DeathPercentage 
From portfolioproject..CovidDeaths 
where location like '%india'
order by 1,2

--Total cases vs population
--Shows what percentage of the population got COVID 
Select location, date, total_cases, population, (total_cases/population)*100 as Percent_populatiopn_infected
From portfolioproject..CovidDeaths 
where location like '%india'
order by 1,2

--Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as Percent_populatiopn_infected
From portfolioproject..CovidDeaths 
Group by location, population
order by Percent_populatiopn_infected desc


--Showing the countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From portfolioproject..CovidDeaths 
where continent is not null
Group by location
order by TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From portfolioproject..CovidDeaths 
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing the continents with the highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From portfolioproject..CovidDeaths 
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as  DeathPercentage 
From portfolioproject..CovidDeaths 
where continent is not null
group by date
order by 1,2


--looking at the total population vs vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

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


