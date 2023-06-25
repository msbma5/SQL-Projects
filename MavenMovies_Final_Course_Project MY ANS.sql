/* 
1. My partner and I want to come by each of the stores in person and meet the managers. 
Please send over the managers’ names at each store, with the full address 
of each property (street address, district, city, and country please).  
*/ 

SELECT
	CONCAT(first_name, " ", last_name) AS "Manager's Name",
    ad.address AS "Street Address",
    ad.district AS District,
    ct.city AS City,
    cy.country AS Country
    
FROM staff sf
JOIN store se
	ON sf.store_id = se.store_id
JOIN address ad
	ON ad.address_id = se.address_id
JOIN city ct
	ON ct.city_id = ad.city_id
JOIN country cy
	ON cy.country_id = ct.country_id;
    

SELECT *
FROM staff;

SELECT *
FROM store;

SELECT *
FROM address;

SELECT *
FROM city;

SELECT *
FROM country;


/*
2.	I would like to get a better understanding of all of the inventory that would come along with the business. 
Please pull together a list of each inventory item you have stocked, including the store_id number, 
the inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost. 
*/

SELECT 
    i.store_id AS store_id,
    i.inventory_id AS inventory_id,
    f.title AS name_of_film,
    f.rating AS film_rating,
    f.rental_rate AS rental_rate,
    f.replacement_cost AS replacement_cost

FROM inventory i 
JOIN film f
	ON i.film_id = f.film_id
ORDER BY inventory_id;

SELECT *
FROM inventory;

SELECT *
FROM film;

SELECT *
FROM rental;


/* 
3.	From the same list of films you just pulled, please roll that data up and provide a summary level overview 
of your inventory. We would like to know how many inventory items you have with each rating at each store. 
*/

SELECT 
    i.store_id AS store_id,
    COUNT(i.inventory_id) AS Number_of_inventory,
    f.rating AS film_rating

FROM inventory i 
JOIN film f
	ON i.film_id = f.film_id
GROUP BY film_rating, store_id;


/* 
4. Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to 
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
We would like to see the number of films, as well as the average replacement cost, and total replacement cost, 
sliced by store and film category. 
*/ 

SELECT
	i.store_id,
    c.name AS Film_Category,
	COUNT(f.film_id) AS number_of_films,
    AVG(replacement_cost) AS Average_replacement_cost,
    SUM(replacement_cost) AS Total_replacement_cost

FROM inventory i 
LEFT JOIN film f
	ON i.film_id = f.film_id
LEFT JOIN film_category fc
	ON fc.film_id = f.film_id
LEFT JOIN category c
	ON c.category_id = fc.category_id
GROUP BY i.store_id, c.name

ORDER BY Total_replacement_cost DESC;

SELECT *
FROM film_category;


/*
5.	We want to make sure you folks have a good handle on who your customers are. Please provide a list 
of all customer names, which store they go to, whether or not they are currently active, 
and their full addresses – street address, city, and country. 
*/

SELECT 
	CONCAT(c.first_name, " ", c.last_name) AS "Customer's Name",
    c.store_id AS Store_Visited,
    c.active AS Active_Level,
    a.address AS Street_Address,
    ct.city AS City,
    cy.country AS Country
    
FROM customer c
LEFT JOIN address a
	ON c.address_id = a.address_id
LEFT JOIN city ct
	ON ct.city_id = a.city_id
LEFT JOIN country cy
	ON cy.country_id = ct.country_id;

SELECT *
FROM customer;

SELECT *
FROM address;

SELECT *
FROM city;

SELECT *
FROM country;

/*
6.	We would like to understand how much your customers are spending with you, and also to know 
who your most valuable customers are. Please pull together a list of customer names, their total 
lifetime rentals, and the sum of all payments you have collected from them. It would be great to 
see this ordered on total lifetime value, with the most valuable customers at the top of the list. 
*/

SELECT
	CONCAT(c.first_name, " ", c.last_name) AS "Customer's Name",
    AS Total_Lifetime_Rental,
    AS Sum_of_all_payments
    
FROM customer c
JOIN payment p
	ON c.customer_id = p.customer_id;



SELECT *
FROM customer;

SELECT *
FROM payment;

SELECT *
FROM rental;






    
/*
7. My partner and I would like to get to know your board of advisors and any current investors.
Could you please provide a list of advisor and investor names in one table? 
Could you please note whether they are an investor or an advisor, and for the investors, 
it would be good to include which company they work with. 
*/


SELECT
	'investor' AS type, 
    first_name, 
    last_name, 
    company_name
FROM investor

UNION 

SELECT 
	'advisor' AS type, 
    first_name, 
    last_name, 
    NULL
FROM advisor;









/*
8. We're interested in how well you have covered the most-awarded actors. 
Of all the actors with three types of awards, for what % of them do we carry a film?
And how about for actors with two types of awards? Same questions. 
Finally, how about actors with just one award? 
*/

SELECT
	CASE 
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN actor_award.awards IN ('Emmy, Oscar','Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
		ELSE '1 award'
	END AS number_of_awards, 
    AVG(CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE 1 END) AS pct_w_one_film
	
FROM actor_award
	

GROUP BY 
	CASE 
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN actor_award.awards IN ('Emmy, Oscar','Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
		ELSE '1 award'
	END
