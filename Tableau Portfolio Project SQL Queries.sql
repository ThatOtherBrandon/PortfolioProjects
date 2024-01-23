/*

Queries used for Tableau Project

*/


-- 1.

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1..['Covid Deaths$']
where continent is not null
order by 1,2


-- 2.

--Will add above code but it is not relevent
-- European union is apart of Europe 

select location, sum(cast(new_deaths as int)) as TotalDeathcount
from PortfolioProject1..['Covid Deaths$']
where continent is null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income',
	'Low income')
group by location
order by TotalDeathcount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject1..['Covid Deaths$']
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. 
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject1..['Covid Deaths$']
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
