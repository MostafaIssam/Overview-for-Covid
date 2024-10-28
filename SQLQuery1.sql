select *
from ProtfolioProject..CovidDeaths
where continent is not null
order by 3,4



-- select data we are going to use it 

select location, date, population, total_cases, total_deaths, new_cases
from ProtfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- looking at total cases vs total deaths 
-- shows liklehood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, ( total_deaths/ total_cases) *100 as DeathPrecentage
from ProtfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2


-- looking at total cases vs population
-- what precentage of population get covid

select location, date, population,  total_cases, total_deaths, (total_cases/ population) *100 as InfectedPeoplePrecentage
from ProtfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2



-- looking at countries have heighst infection rate compared to population

select location, population, Max(total_cases) as HeighstInfectionCount, Max(total_cases/ population) *100 as
InfectedPeoplePrecentage
from ProtfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 4 desc



-- Break things down by continent 
-- showing continent with heighst Death per population 

select continent, Max(total_deaths) as TotalDeathCount
from ProtfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc




-- Showing sum of cases and deaths in united states per day

select  date , SUM(new_cases) as CasesPerDay, SUM(new_deaths) as DeathsPerDay 
from ProtfolioProject..CovidDeaths
where location like '%states%'
group by date
order by date




-- showing sum of cases,deaths and percent of deaths vs cases across the world per day 

select  SUM(new_cases) as totCasesPerday, SUM(new_deaths) as totDeathsPerDay , (SUM(new_deaths)/SUM(new_cases))*100
as DeathsPercentage
from ProtfolioProject..CovidDeaths
--group by date
Having  SUM(new_deaths) is not null
       and SUM(new_deaths) != 0
order by 1,2



-- joining two tables


select *
from ProtfolioProject..CovidVaccinations CV
join ProtfolioProject..CovidDeaths CD
on CD.location = CV.location
AND CD.date = CV.date



-- looking at total population vs vaccinations


select CD.continent, CD.location, CD.date, CD.population, 
       CV.new_vaccinations,
	   SUM (convert(int,CV.new_vaccinations)) over (partition by CD.location order by CD.location ,CD.date) 
	   as rollingPeopleVaccinated
from ProtfolioProject..CovidVaccinations CV

join ProtfolioProject..CovidDeaths CD
on CD.location = CV.location
AND CD.date = CV.date

where CD.continent is not null
group by  CD.continent, CD.location, CD.date, CD.population, 
       CV.new_vaccinations
order by 2,3
 


-- use CTE 

with PopvsVac ( continent , location , date , population,  new_vaccinations, rollingPeopleVaccinated )
as (
select CD.continent, CD.location, CD.date, CD.population, 
       CV.new_vaccinations,
	   SUM (convert(int,CV.new_vaccinations)) over (partition by CD.location order by CD.location ,CD.date) 
	   as rollingPeopleVaccinated
from ProtfolioProject..CovidVaccinations CV

join ProtfolioProject..CovidDeaths CD
on CD.location = CV.location
AND CD.date = CV.date

where CD.continent is not null
group by  CD.continent, CD.location, CD.date, CD.population, 
       CV.new_vaccinations
)
select * , (rollingPeopleVaccinated/ population)*100
from PopvsVac





-- temp table 

Drop table #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric 
)
insert into #PercentPeopleVaccinated
select CD.continent, CD.location, CD.date, CD.population, 
       CV.new_vaccinations,
	   SUM (convert(int,CV.new_vaccinations)) over (partition by CD.location order by CD.location ,CD.date) 
	   as rollingPeopleVaccinated
from ProtfolioProject..CovidVaccinations CV

join ProtfolioProject..CovidDeaths CD
on CD.location = CV.location
AND CD.date = CV.date

--where CD.continent is not null
select * , (rollingPeopleVaccinated/ population)*100
from #PercentPeopleVaccinated






--  create viewing to store data for later viewing 

Create View PercentagePeopleVaccinated as

select CD.continent, CD.location, CD.date, CD.population, 
       CV.new_vaccinations,
	   SUM (convert(int,CV.new_vaccinations)) over (partition by CD.location  order by  CD.location ,CD.date) 
	   as rollingPeopleVaccinated
from ProtfolioProject..CovidVaccinations CV

join ProtfolioProject..CovidDeaths CD
on CD.location = CV.location
AND CD.date = CV.date




select *
from PercentagePeopleVaccinated