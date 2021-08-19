
select *
from PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

--select *
--from PortfolioProject..CovidVaccination
--Order by 3,4

--Slecting data that is required now 
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
Order by 1,2

--total case  VS total death

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathRate
from PortfolioProject..CovidDeaths
where  location = 'India' 
Order by 1,2


--total population VS total cases
select location,date,population,total_cases,(total_cases/population)*100 as InfectedRate
from PortfolioProject..CovidDeaths
where  location = 'India' 
Order by 1,2

---look at the countries higest highest infection rate campared population

select location,population,MAX(total_cases) Higestcount ,MAX((total_cases/population)*100)as InfectedRate
from PortfolioProject..CovidDeaths
Group BY location,population
Order by InfectedRate DESC

---showing max death per country
select location,MAX(cast(total_deaths AS INT)) TotalDeath 
from PortfolioProject..CovidDeaths
where continent is not null
Group BY location
Order by TotalDeath DESC

---showing max death per continent 
select continent,MAX(cast(total_deaths AS INT)) TotalDeath 
from PortfolioProject..CovidDeaths
where continent is not null
Group BY continent
Order by TotalDeath DESC


--Death rate ,infection , death over word
select Sum(new_cases) as Totalcase ,Sum(cast(new_deaths AS INT)) as TotalDeath,Sum(cast(new_deaths as int) )/Sum(new_cases)*100 as DeathRate
from PortfolioProject..CovidDeaths
Order by 1,2

--change data type of col

ALTER TABLE CovidVaccination
ALTER COLUMN new_vaccinations INT;


--and dea.date='2021-02-18 00:00:00.000' and dea.location='Albania'

--joining 2 tables 

--SELECT * INTO #TEMPBLOCKEDDATES FROM 
--(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac 
	on dea.location=vac.location and 
	dea.date=vac.date
where dea.continent is not null 
--)


-- creating temp table otr CTE
--to find max population vacinated

;WITH ResultSet(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as (
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac 
	on dea.location=vac.location and 
	dea.date=vac.date
where dea.continent is not null 
)

select location,
MAX((RollingPeopleVaccinated/population)*100) as MAXPopulationVSVaccination from ResultSet
Group by location


--creating te,p  table using #
DROP TABLE  if exists #PopVSVac
create table #PopVSVac (
continent nvarchar(255),location nvarchar(255),date datetime ,population numeric ,new_vaccinations numeric ,RollingPeopleVaccinated numeric)

insert into #PopVSVac  
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac 
	on dea.location=vac.location and 
	dea.date=vac.date
where dea.continent is not null 

select location,
MAX((RollingPeopleVaccinated/population)*100) as MAXPopulationVSVaccination from #PopVSVac
Group by location
order by 1


--creating view
Create View PercetagePopulationVSVaccination as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac 
	on dea.location=vac.location and 
	dea.date=vac.date
where dea.continent is not null 
