
Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select data that we will use
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- total cases vs total deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercantage
From PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

--total cases vs population
Select Location, date, population, total_cases, (total_cases/population)*100 as infectpopulation
From PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

-- highest infection rate wrt population
Select Location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as InfectedPopulation
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Group by Location, Population
order by InfectedPopulation desc

--Countries with highest death count
Select Location, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

--continent wise highest death count
Select location, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

--global numbers
Select SUM(new_cases) as NewCases, sum(cast(new_deaths as bigint)) as NewDeaths, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercenatge
From PortfolioProject..CovidDeaths
--Where location like '%india%'
where continent is not null
--group by date
order by 1,2

--total population vs vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--rollover count
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

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