--select * 
--from Portfolio_Project..CovidDeaths
--order by 3,4
--select * 
--from Portfolio_Project..CovidVaccination
--order by 3,4

-- Select data to be used
select location, date, total_cases,new_cases,total_deaths,population
from Portfolio_Project..CovidDeaths
order by 1,2

Select * from CovidDeaths
Alter table [CovidDeaths]
Alter column[total_deaths] float

Select * from CovidDeaths
Alter table [CovidDeaths]
Alter column[total_cases] float

-- Total cases vs total deaths
-- Likelihood of dying from Covid in your country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where location like '%United Kingdom%'
order by 1,2

-- looking at total cases vs Population
-- Finding the % of population with Covid
select location, date, total_cases,population, (total_cases/population)*100 as PercentofPopulationInfected
from Portfolio_Project..CovidDeaths
where location like '%United Kingdom%'
order by 1,2

-- What are the countries with the highest infection rates compared to the rest of the Population
select location, Max(total_cases) as HighestInfectionCount,population, Max((total_cases/population))*100 as PercentofPopulationInfected
from Portfolio_Project..CovidDeaths
group by location, population
order by PercentofPopulationInfected desc

-- Showing countries with highest deathcount per location
select location, Max(total_deaths)  as TotalDeathCount
from Portfolio_Project..CovidDeaths
where continent is not null -- adding this prevented results where continents were coming up in the locatiob column
group by location, population
order by TotalDeathCount desc

-- Break by continent with highest death count per population

select continent, Max(total_deaths)  as TotalDeathCount
from Portfolio_Project..CovidDeaths
where continent is not null -- adding this prevented results where continents were coming up in the locatiob column
group by continent
order by TotalDeathCount desc

-- Global Numbers
select date, SUM(new_cases) as Total_NewCases, SUM(new_deaths) as Total_NewDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where continent is not null 
AND new_cases != 0 
Group by Date
order by 1,2

-- Global Numbers
select SUM(new_cases) as Total_NewCases, SUM(new_deaths) as Total_NewDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where continent is not null 
AND new_cases != 0 
--Group by Date
order by 1,2

-- Joining the two seperate tables - Total population vs vaccinated population
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as float)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingCount_Vaccinated
--(RollingCount_Vaccinated/population)*100 as Percentof_VaccinatedPopulation
from Portfolio_Project..CovidDeaths as cd
join Portfolio_Project..CovidVaccination as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--group by cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
order by 1,2,3

-- Cannot reference an alias in the same clause
-- A CTE must be created:

WITH PopVVac (continent, location, date, population, new_vaccination, RollingCount_Vaccinated)
AS
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as float)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingCount_Vaccinated
--(RollingCount_Vaccinated/population)*100 as Percentof_VaccinatedPopulation
from Portfolio_Project..CovidDeaths as cd
join Portfolio_Project..CovidVaccination as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null)
select *, (RollingCount_Vaccinated/population)*100
From PopVVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCount_Vaccinated numeric)

Insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as float)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingCount_Vaccinated
--(RollingCount_Vaccinated/population)*100 as Percentof_VaccinatedPopulation
from Portfolio_Project..CovidDeaths as cd
join Portfolio_Project..CovidVaccination as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
select *, (RollingCount_Vaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View for Data vis

Create View PopVaccinatedPercentage as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as float)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingCount_Vaccinated
--(RollingCount_Vaccinated/population)*100 as Percentof_VaccinatedPopulation
from Portfolio_Project..CovidDeaths as cd
join Portfolio_Project..CovidVaccination as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
