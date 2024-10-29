SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[population]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
  FROM [PortfolioProject].[dbo].['COVID Deaths$']

  select *
  from ['COVID Deaths$']
  where continent is not null

  select location, date, total_cases, new_cases, total_deaths, population
  from dbo.['COVID Deaths$']
  order by 1, 3 asc

  --TOTAL CASES VS TOTAL DEATHS. LIKELYHOOD OF DEATH FROM COVID IN COUNTRIES

   select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100
  from dbo.['COVID Deaths$']
  where total_cases > 0 and total_deaths > 0 and location = 'united states'
  order by 1, 2


  --TOTAL CASES VS POPULATION

  select location, date, total_cases, population, (total_cases/population)*100
  from dbo.['COVID Deaths$']
  where total_cases > 0 and location = 'united states'
  order by 1, 3 asc

  select location, total_cases
  from ['COVID Deaths$']
  order by total_cases desc


  --COUNTRIES WITH HIGHEST INFECTION RATES TO POPULATION
  
  select location, population, max(total_cases) highestinfcount, max((total_cases/population))*100 percentageofpopulationinf
  from dbo.['COVID Deaths$']
  group by location, population
  order by percentageofpopulationinf desc

  --COUNTRIES WITH HIGHEST DEATH COUNT TO POPULATION

  select location, population, max(total_deaths) TotalDeathCount
  from dbo.['COVID Deaths$']
  where continent is not null
  group by location, population
  order by TotalDeathCount desc

  --CONTINENTS WITH DEATH COUNT

  select location, max( cast (total_deaths as int)) TotalDeathCount
  from dbo.['COVID Deaths$']
  where continent is null
  group by location
  order by TotalDeathCount desc


  --TOTAL DEATHS IN AFRICAN COUNTRIES

  select location, max(total_deaths) TDC
  from dbo.['COVID Deaths$']
  where continent = 'africa'
  group by location
  order by TDC desc


  select continent, avg(total_cases)
  from dbo.['COVID Deaths$']
  group by continent


  --GLOBAL NUMBERS

  --ERROR, WORK ON
select date, sum(new_cases) totalcases,sum(new_deaths) totaldeaths, total_deaths/total_cases *100 as DeathPercentage
from dbo.['COVID Deaths$']
where new_cases > 0 and new_deaths > 0 and continent is not null
group by date, total_deaths, total_cases
order by 1, 2

select  sum(new_deaths) totalcases, max(total_deaths) totaldeaths--,sum(total_deaths), sum(total_deaths)/sum(total_cases) *100 as DeathPercentage
from dbo.['COVID Deaths$']
where new_cases > 0 and new_deaths > 0 and continent is not null

order by 1, 2

select date, new_cases
from dbo.['COVID Deaths$']
where new_cases > 0

--select date, new_cases, total_cases
--from dbo.['COVID Deaths$']


--JOINED TABLE



select location, population, max(total_cases) highestinfxcount, max(total_cases/population)*100 percentpopinfected
from ['COVID Deaths$']
group by location, population
order by percentpopinfected desc





--TEST RUN FOR Partition by
SELECT vac.new_vaccinations, dea.location, MAX(CONVERT(FLOAT,vac.new_vaccinations)) over (PARTITION by dea.location), MAX(CONVERT(FLOAT,vac.new_vaccinations))
from ['COVID Vaccination$'] vac join ['COVID Deaths$'] dea
ON dea.location = vac.location
	and dea.date = vac.date
where dea.location = 'afghanistan'
group by dea.location, vac.new_vaccinations




--TOTAL POPULATION VS VACCINATION

select dea.continent, dea.location, dea.date,vac.new_vaccinations, dea.population
from ['COVID Deaths$'] dea join ['COVID Vaccination$'] vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.location = 'canada'
order by  2, 3


--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated) 
as
 (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(FLOAT,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) Rollingpeoplevaccinated--, (Rollingpeoplevaccinated/dea.population)*100
FROM ['COVID Deaths$'] dea join ['COVID Vaccination$'] vac
ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by  2, 3
)
select *, (Rollingpeoplevaccinated/population)*100
FROM PopvsVac
order by location, date


--TEMP TABLE


DROP Table if exists #PercentPopVac
CREATE TABLE #PercentPopVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations float,
Rollingpeoplevaccinated numeric
)

INSERT INTO #PercentPopVac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(FLOAT,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) Rollingpeoplevaccinated--, (Rollingpeoplevaccinated/dea.population)*100
FROM ['COVID Deaths$'] dea join ['COVID Vaccination$'] vac
ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by  2, 3

SELECT  *, (rollingpeoplevaccinated/population)*100
FROM #PercentPopVac




--creating view to store data for visualization later

CREATE view PercentPopVac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(FLOAT,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) Rollingpeoplevaccinated--, (Rollingpeoplevaccinated/dea.population)*100
FROM ['COVID Deaths$'] dea join ['COVID Vaccination$'] vac
ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by  2, 3

SELECT *
from PercentPopVac