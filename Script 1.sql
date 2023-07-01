/* 
Question 1 - How many olympics games have been held?
*/

SELECT 
	COUNT(DISTINCT Games) AS 'Total Olympics Games'
FROM athlete_events
;



/* 
Question 2 - List down all Olympics games held so far.
*/

SELECT
	DISTINCT (Year),
	Season,
	City
FROM athlete_events
ORDER BY Year
;

/* 
Question 3 - Mention the total no of nations who participated in each olympics game?
*/

SELECT 
	DISTINCT(Games),
	COUNT(Team) AS Total_countries

FROM athlete_events
GROUP BY Games,Team
ORDER BY Games

;
/* 
Question 4 - Which year saw the highest and lowest no of countries participating in olympics?
*/


/* 
Question 5 - Which nation has participated in all of the olympic games?
*/



/* 
Question 6 - Identify the sport which was played in all summer olympics.
*/


/* 
Question 7 - Which Sports were just played only once in the olympics?
*/


/* 
Question 8 - Fetch the total no of sports played in each olympic games.
*/


/* 
Question 9 - Fetch details of the oldest athletes to win a gold medal.
*/

/* 
Question 10 - Find the Ratio of male and female athletes participated in all olympic games.
*/

