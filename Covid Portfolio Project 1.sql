--SELECT *
--FROM PortfolioProject1..CovidDeath


--SELECT *
--FROM PortfolioProject1..CovidVaccinations$


--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject1..CovidDeath
--ORDER BY 1,2

--SELECT *
--FROM PortfolioProject1..CovidDeath
--ALTER TABLE CovidDeath
--ALTER COLUMN total_deaths varchar(50)
--ALTER TABLE CovidDeath
--ALTER COLUMN total_cases varchar(50)



-- looking at Total cases vs Total Deaths

--SELECT location, date, total_cases, total_deaths
--	,CONVERT(decimal(15,3),total_cases)
--	,CONVERT(decimal(15,3),total_deaths)
--	,CONVERT(decimal(15,3), (CONVERT(decimal(15,3),total_deaths)/ CONVERT(decimal(15,3),total_cases)))*100 as DeathPercentage
--FROM PortfolioProject1..CovidDeath
--WHERE location like '%india%'
--ORDER BY 1,2

--looking at Total cases at population

--SELECT location, date, total_cases, population,
--	CONVERT(decimal(15,3), (CONVERT(decimal,total_cases)/CONVERT(decimal,population)))*100 AS CasesPercentage
--FROM PortfolioProject1..CovidDeath
--WHERE location like '%India%'
--ORDER BY 1,2

--looking for Highest with high covide infected cases compared to population

SELECT location, population, MAX(total_cases) AS HighestCovidCases, population,
	MAX(CONVERT(decimal(15,3), (CONVERT(decimal,total_cases)/CONVERT(decimal,population))))*100 AS CasePercentage
FROM PortfolioProject1..CovidDeath
GROUP BY location, population
ORDER BY CasePercentage desc


-- Looking for Highest death rate compared to location

SELECT location, MAX(CAST(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject1..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount desc

-- Lookiing for the Death rate based on the Continent

SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathRate
FROM PortfolioProject1..CovidDeath
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathRate desc


--Global Numbers

SELECT  SUM(new_cases) as TotalCases, SUM(new_deaths) AS  TotalDeath,
	  SUM(new_deaths)/SUM(new_cases)*100 AS DeathratePercentage	
FROM PortfolioProject1..CovidDeath
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking for Total popultation vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vcc.new_vaccinations,
	SUM(CONVERT(float,vcc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeath AS dea
JOIN PortfolioProject1..CovidVaccinations$ AS vcc
	ON dea.location = vcc.location
	AND dea.date = vcc.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
	
-- USE CTE for temporaty table

WITH PopvsVCC (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vcc.new_vaccinations,
	SUM(CONVERT(float,vcc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeath AS dea
JOIN PortfolioProject1..CovidVaccinations$ AS vcc
	ON dea.location = vcc.location
	AND dea.date = vcc.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVCC


--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vcc.new_vaccinations,
	SUM(CONVERT(float,vcc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeath AS dea
JOIN PortfolioProject1..CovidVaccinations$ AS vcc
	ON dea.location = vcc.location
	AND dea.date = vcc.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

ORDER BY 2,3


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vcc.new_vaccinations,
	SUM(CONVERT(float,vcc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeath AS dea
JOIN PortfolioProject1..CovidVaccinations$ AS vcc
	ON dea.location = vcc.location
	AND dea.date = vcc.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated