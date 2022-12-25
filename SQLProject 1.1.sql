
Use [Portfolio Project 1.1]


-- COVID19 Data Exploration
-- Skills Used : Temp Table, Creating View, Inner Joins, CTE, Aggregate Functions, Converting Data Types, Windows Function


-- Looking at the data set that we are working on.
	-- Excludes dataset which identifies a continent as a country.

SELECT *
FROM [Portfolio Project 1.1]..[CovidDeaths]
WHERE continent IS NOT NULL 
ORDER BY 3,4



-- Narrowing down the dataset and looking at relevant columns.

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population

FROM [Portfolio Project 1.1]..[CovidDeaths]
WHERE continent IS NOT NULL 
ORDER BY 1,2



-- Looking at the percentage of Total Cases Vs Total Deaths in Singapore.

SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)* 100 As Percentage_of_Death

FROM [Portfolio Project 1.1]..[CovidDeaths]
WHERE location = 'Singapore'
ORDER BY 1,2

-- Looking at the percentage of Total Cases vs Population in Singapore.

SELECT 
	location,
	date,
	total_cases,
	population,
	(total_cases/population)* 100 As Percentage_of_Infected_Indiviuals


FROM [Portfolio Project 1.1]..[CovidDeaths]
WHERE location = 'Singapore'
ORDER BY 1,2


-- Looking at countries with highest Infection Rate VS Population.

SELECT 
	location,
	population,
	MAX(total_cases) AS Highest_Infection_Count,
	MAX((total_cases/population))* 100 As Percentage_of_Contracted_Indiviuals


FROM [Portfolio Project 1.1]..[CovidDeaths]
WHERE continent IS NOT NULL 
GROUP BY location,population
ORDER BY Percentage_of_Contracted_Indiviuals DESC


--Showing countries with highest death count.


SELECT 
	location,
	MAX (cast(total_deaths AS int)) AS Total_Death_Count


FROM [Portfolio Project 1.1]..[CovidDeaths]
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY Total_Death_Count DESC


--Show number of deaths according to continent.

SELECT 
	continent,
	MAX (cast(total_deaths AS int)) AS Total_Death_Count


FROM [Portfolio Project 1.1]..[CovidDeaths]
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY Total_Death_Count DESC


-- Looking at Global Numbers.

SELECT 
	date,
	SUM(new_cases) AS Global_New_Cases,
	SUM(cast(new_deaths AS int)) AS Global_New_Deaths,
	SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS Global_Death_Percentage


FROM [Portfolio Project 1.1]..[CovidDeaths]
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population VS Vaccinations

SELECT
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations

FROM [Portfolio Project 1.1]..[CovidDeaths] cd
JOIN [Portfolio Project 1.1]..[CovidVaccinations] cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

--  Total Population vs Vaccination WITH partition by

SELECT
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM (CAST(cv.new_vaccinations AS bigint)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS Cumulative_New_Vaccinations

FROM [Portfolio Project 1.1]..[CovidDeaths] cd
JOIN [Portfolio Project 1.1]..[CovidVaccinations] cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

-- USING CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Cumulative_New_Vaccinations)
as
(
SELECT
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM (CAST(cv.new_vaccinations AS bigint)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS Cumulative_New_Vaccinations

FROM [Portfolio Project 1.1]..[CovidDeaths] cd
JOIN [Portfolio Project 1.1]..[CovidVaccinations] cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT * , (Cumulative_New_Vaccinations/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Cumulative_New_Vaccinations numeric
)
Insert Into #PercentPopulationVaccinated
SELECT
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM (CAST(cv.new_vaccinations AS bigint)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS Cumulative_New_Vaccinations

FROM [Portfolio Project 1.1]..[CovidDeaths] cd
JOIN [Portfolio Project 1.1]..[CovidVaccinations] cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT * , (Cumulative_New_Vaccinations/Population)*100 AS Percentage_Of_New_Vaccinations
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS 
SELECT
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM (CAST(cv.new_vaccinations AS bigint)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS Cumulative_New_Vaccinations

FROM [Portfolio Project 1.1]..[CovidDeaths] cd
JOIN [Portfolio Project 1.1]..[CovidVaccinations] cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3
