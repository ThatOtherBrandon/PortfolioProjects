
Select * 
from PortfolioProject1..['Covid Deaths$']
where continent is not null
order by 3,4

--Select * 
--from PortfolioProject1..['Covid Vaccinations$']
--order by 3,4
--Select the data we will be using 
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..['Covid Deaths$']
order by 1,2

--Looking at total cases VS total deaths 

select Location, date, total_cases, cast(total_deaths as int) as TotalDeathInt, (cast (total_deaths as float)) / (cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject1..['Covid Deaths$']
order by 1,2

-- ChatGPT help 
-- Shows the liklyhood of dying from covid in a country 
SELECT
    Location,
    date,
    total_cases,
    total_deaths,
    CASE
        WHEN TRY_CAST(total_cases AS DECIMAL(18, 2)) = 0 THEN NULL  -- handle division by zero
        ELSE (TRY_CAST(total_deaths AS DECIMAL(18, 2)) / TRY_CAST(total_cases AS DECIMAL(18, 2))) * 100
    END AS DeathPercentage
FROM
    PortfolioProject1..['Covid Deaths$']
where location like '%states%'
ORDER BY
    1, 2;

-- Looking at total cases vs Population 
--Shows what percentage got covid 

select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfection
from PortfolioProject1..['Covid Deaths$']
where location like '%states%'
order by 1,2


-- Lookin at country with highest infection rates compared to population 

select continent, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
	PercentPopulationInfected
from PortfolioProject1..['Covid Deaths$']
--where location like '%states%'
where continent is not null
group by continent, population
order by PercentPopulationInfected desc

-- Showing The countries with the higheset death count per population 

select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..['Covid Deaths$']
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--NOW LETS BREAK THINGS DOWN BY CONTINENT



-- Showing the contintents with the highest death counts per population 
--make a view out of this 

select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..['Covid Deaths$']
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
--cast(total_deaths as int) as TotalDeathInt, (cast (total_deaths as float)) / (cast(total_cases as float))*100 as DeathPercentage
-- Same thing figure out why this wont work
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
from PortfolioProject1..['Covid Deaths$']
--where location like '%states%'
where continent is not null
group by date
order by 1,2



-- Figure out why this wont work
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
from PortfolioProject1..['Covid Deaths$']
--where location like '%states%'
where continent is not null
group by date
order by 1,2


-- Whole population in one number
SELECT
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths AS INT)) as total_deaths, 
    SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)), 0) * 100.0 as DeathPercentage
FROM
    PortfolioProject1..['Covid Deaths$']
WHERE
    continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;

--Whole population that goes by date
SELECT
    date,
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths AS INT)) as total_deaths, 
    SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)), 0) * 100.0 as DeathPercentage
FROM
    PortfolioProject1..['Covid Deaths$']
WHERE
    continent IS NOT NULL
GROUP BY
    date
ORDER BY
    1, 2;






-- Looking at total population vs vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1..['Covid Deaths$'] dea
join PortfolioProject1..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 



-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1..['Covid Deaths$'] dea
join PortfolioProject1..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



-- TEMP Table

drop table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1..['Covid Deaths$'] dea
join PortfolioProject1..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated;


-- Creating View to store data later for visualization
DROP VIEW PortfolioProject.PercentPopulationVaccinated;

create view PercentPopulationVaccinated
 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1..['Covid Deaths$'] dea
join PortfolioProject1..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


CREATE VIEW PortfolioProject1.PercentPopulationVaccinated
AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    PortfolioProject1..['Covid Deaths$'] dea
JOIN
    PortfolioProject1..['Covid Vaccinations$'] vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

select PortfolioProject1
from INFORMATION_SCHEMA.SCHEMATA
where PortfolioProject1 = 'PortfolioProject1';

SELECT schema_name
FROM INFORMATION_SCHEMA.SCHEMATA
WHERE schema_name = 'PortfolioProject1';

CREATE SCHEMA PortfolioProject1;

CREATE VIEW dbo.PercentPopulationVaccinated
AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    PortfolioProject1..['Covid Deaths$'] dea
JOIN
    PortfolioProject1..['Covid Vaccinations$'] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;


select * 
from dbo.PercentPopulationVaccinated;