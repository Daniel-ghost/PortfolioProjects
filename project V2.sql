

  SELECT *
  FROM [COVID Deaths]
  WHERE continent is not null

  SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM dbo.[COVID Deaths]
  ORDER BY 1, 3 

  --TOTAL CASES VS TOTAL DEATHS. LIKELYHOOD OF DEATH FROM COVID IN COUNTRIES

  SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100
  FROM dbo.[COVID Deaths]
  WHERE total_cases > 0 and total_deaths > 0 and location = 'united states'
  ORDER BY 1, 2


  --TOTAL CASES VS POPULATION

  SELECT location, date, total_cases, population, (total_cases/population)*100
  FROM dbo.[COVID Deaths]
  WHERE total_cases > 0 and location = 'united states'
  ORDER BY 1, 3 asc

  SELECT location, total_cases
  FROM [COVID Deaths]
  ORDER BY total_cases desc


  --COUNTRIES WITH HIGHEST INFECTION RATES TO POPULATION
  
  SELECT location, population, max(total_cases) highestinfcount, max((total_cases/population))*100 percentageofpopulationinf
  FROM dbo.[COVID Deaths]
  GROUP BY location, population
  ORDER BY percentageofpopulationinf desc

  --COUNTRIES WITH HIGHEST DEATH COUNT TO POPULATION

  SELECT location, population, max(total_deaths) TotalDeathCount
  FROM dbo.[COVID Deaths]
  WHERE continent is not null
  GROUP BY location, population
  ORDER BY TotalDeathCount desc

  --CONTINENTS WITH DEATH COUNT

  SELECT location, max( cast (total_deaths as int)) TotalDeathCount
  FROM dbo.[COVID Deaths]
  WHERE continent is null
  GROUP BY location
  ORDER BY TotalDeathCount desc


  --TOTAL DEATHS IN AFRICAN COUNTRIES

  SELECT location, max(total_deaths) TDC
  FROM dbo.[COVID Deaths]
  WHERE continent = 'africa'
  GROUP BY location
  ORDER BY TDC desc


  SELECT continent, avg(total_cases)
  FROM dbo.[COVID Deaths]
  GROUP by continent


  --GLOBAL NUMBERS

  --ERROR, WORK ON
SELECT date, sum(new_cases) totalcases,sum(new_deaths) totaldeaths, total_deaths/total_cases *100 as DeathPercentage
FROM dbo.[COVID Deaths]
WHERE new_cases > 0 and new_deaths > 0 and continent is not null
GROUP BY date, total_deaths, total_cases
ORDER BY 1, 2

SELECT  sum(new_deaths) totalcases, max(total_deaths) totaldeaths--,sum(total_deaths), sum(total_deaths)/sum(total_cases) *100 as DeathPercentage
FROM dbo.[COVID Deaths]
WHERE new_cases > 0 and new_deaths > 0 and continent is not null

ORDER BY 1, 2

SELECT date, new_cases
FROM dbo.[COVID Deaths]
WHERE new_cases > 0

--select date, new_cases, total_cases
--from dbo.['COVID Deaths$']


--JOINED TABLE



SELECT location, population, max(total_cases) highestinfxcount, max(total_cases/population)*100 percentpopinfected
FROM [COVID Deaths]
GROUP BY location, population
ORDER BY percentpopinfected desc





--TEST RUN FOR Partition by
SELECT vac.new_vaccinations, dea.location, MAX(CONVERT(FLOAT,vac.new_vaccinations)) over (PARTITION by dea.location), MAX(CONVERT(FLOAT,vac.new_vaccinations))
FROM [portfolioproject].[dbo].[COVID Vaccination] vac join [PortfolioProject].[dbo].[COVID Deaths] dea
ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location = 'afghanistan'
GROUP by dea.location, vac.new_vaccinations




--TOTAL POPULATION VS VACCINATION

SELECT dea.continent, dea.location, dea.date,vac.new_vaccinations, dea.population
FROM [COVID Deaths] dea join [COVID Vaccination] vac
ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
and dea.location = 'canada'
ORDER BY  2, 3


--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated) 
as
 (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(FLOAT,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) Rollingpeoplevaccinated--, (Rollingpeoplevaccinated/dea.population)*100
FROM [COVID Deaths] dea join [COVID Vaccination] vac
ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by  2, 3
)
SELECT *, (Rollingpeoplevaccinated/population)*100
FROM PopvsVac
ORDER BY location, date


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
FROM [COVID Deaths] dea join [COVID Vaccination] vac
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
FROM [COVID Deaths] dea join [COVID Vaccination] vac
ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by  2, 3

SELECT *
from PercentPopVac