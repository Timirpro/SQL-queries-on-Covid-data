select * from PortfolioProject..CovidDeaths 
Where continent is not null
order by 3,4

-- Выборка данных для использования

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2 

-- Сравнение случаев заражения и случаев смерти, вероятность смерти

select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%russia%'
order by 1,2 

-- Сравнение количества зараженных и численности населения, сколько процентов заразилось

select Location, date, population, total_cases, total_deaths, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where location like '%russia%'
order by 1,2 

-- Страны с самым высокой долей заражения

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectedPercentage
from PortfolioProject..CovidDeaths
-- where location like '%russia%'
Group by Location, population
order by InfectedPercentage desc

-- Страны с самой высокой смертностью

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Разбор данных по отдельным континентам

-- Континенты с самой высокой смертностью

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Глобальные показатели
-- по датам

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%russia%'
where continent is not null
group by date
order by 1,2 

-- за все время

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%russia%'
where continent is not null
-- group by date
order by 1,2


-- Доля вакцинированного населения


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Использование CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From popvsVac

-- Использование TEMP TABLE

Drop Table if exists #PrecentPopulationVaccinated
Create Table #PrecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PrecentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3
select *, (RollingPeopleVaccinated/Population)*100
From #PrecentPopulationVaccinated
