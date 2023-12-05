select *
from ProjectPortfolio..[covid-deaths]
where continent is not null and total_deaths is not null
order by 3,4

select *
from ProjectPortfolio..CovidVaccinations
where location = 'Afghanistan'
order by 3,4

select *
from ProjectPortfolio..covidvaccined

-- Selecting Data to be used
select location, date, total_cases, new_cases, total_deaths, population
from [covid-deaths]
order by 6;

-- Percentage Deaths Per Cases
select location, date, total_cases,  total_deaths as 'all deaths',
 CAST(total_deaths as float) / total_cases *100 AS "death per case"
from ProjectPortfolio..[covid-deaths]
where location like '%States%'
order by 1,2 desc

-- Percentage Cases Per Population
select DISTINCT(location), date, total_cases,  population, 
(total_cases) / population * 100 AS CasesPerPopulationPercentage
from ProjectPortfolio..[covid-deaths]
where total_cases < 409999999 
-- location != 'World'
order by 2 desc, CasesPerPopulationPercentage desc


select location, population, MAX(total_cases) as highestinfected,
max((total_cases / population)) * 100 as percentagepopulationinfected
from ProjectPortfolio..[covid-deaths]
group by location, population
order by percentagepopulationinfected desc

-- showing countries with highest death count population
select location, max(total_deaths) as totaldeathscount
from ProjectPortfolio..[covid-deaths]
where continent is null
group by location
order by 2 desc

-- Grouping by continent
select continent, max(total_deaths) as totaldeathscount
from ProjectPortfolio..[covid-deaths]
where continent is not null
group by continent
order by 2 desc

-- showing the continents with the highest deaths count per population
select location, max(total_deaths) as totaldeathscount
from ProjectPortfolio..[covid-deaths]
where continent is null
group by location
order by 2 desc

-- Global Numbers
select date, sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, 
sum(new_deaths) / sum(new_cases) * 100 as deathspercentage
from ProjectPortfolio..[covid-deaths]
where continent is not null and continent != 'world' and new_cases != 0 
group by date
order by date desc

selecT sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, 
sum(new_deaths) / sum(new_cases) * 100 as deathspercentage
from ProjectPortfolio..[covid-deaths]
where continent is not null and continent != 'world' and new_cases != 0 
order by 1,2 desC

select dea.location, dea.date, vac.continent
from ProjectPortfolio..covidvaccined vac
	join ProjectPortfolio..[covid-deaths] dea
	on dea.location = vac.location
	and dea.date = vac.date
and dea.date = vac.date

-- New Vaccinations
select dea.location, dea.date, vac.continent, vac.new_vaccinations, 
dea.new_cases / dea.new_deaths as deathsrate
from ProjectPortfolio..covidvaccined vac
	join ProjectPortfolio..[covid-deaths] dea
	on dea.location = vac.location
	and dea.date = vac.date
where vac.continent is not null and dea.new_deaths != 0
order by 2 desc,deathsrate desc

--CTE
with PopvsVac (location, date, continents, new_vaccinations, population, 
Rollingpeoplevaccinated) as
(
select dea.location, dea.date, vac.continent, vac.new_vaccinations, dea.population,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location 
order by dea.location, dea.date) as Rollingpeoplevaccinated
from ProjectPortfolio..covidvaccined vac
	join ProjectPortfolio..[covid-deaths] dea
	on dea.location = vac.location
	and dea.date = vac.date
where vac.continent is not null 
)
select *, (Rollingpeoplevaccinated/population) *100 as RollingpeoplevaccinatedPercentage
from PopvsVac
where Rollingpeoplevaccinated is not null
order by date desc, Rollingpeoplevaccinated desc

-- TEMP TABLE
DROP Table if exists #populationpercentagevaccinated
create table #populationpercentagevaccinated
(location nvarchar(255),
 date datetime, 
 continents nvarchar(255), 
 new_vaccinations numeric, 
 population numeric, 
Rollingpeoplevaccinated numeric) 
insert into #populationpercentagevaccinated

select dea.location, dea.date, vac.continent, vac.new_vaccinations, dea.population,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location 
order by dea.location, dea.date) as Rollingpeoplevaccinated
from ProjectPortfolio..covidvaccined vac
	join ProjectPortfolio..[covid-deaths] dea
	on dea.location = vac.location
	and dea.date = vac.date
where vac.continent is not null 
-- order by 1,3
select *, (Rollingpeoplevaccinated/population) *100
from #populationpercentagevaccinated

-- creating view to store data for later visualization
CREATE VIEW populationpercentagevaccinate as
select dea.location, dea.date, vac.continent, vac.new_vaccinations, dea.population,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location 
order by dea.location, dea.date) as Rollingpeoplevaccinated
from ProjectPortfolio..covidvaccined vac
	join ProjectPortfolio..[covid-deaths] dea
	on dea.location = vac.location
	and dea.date = vac.date
where vac.continent is not null 
-- order by 1,3

select *
from populationpercentagevaccinate