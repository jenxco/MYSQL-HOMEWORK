USE sakila;

# 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT
   UPPER(
   CONCAT(first_name, ' ', last_name)
)  AS 'Actor Name'
   FROM actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#        What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
	WHERE first_name = 'Joe';
    
#  2b. Find all actors whose last name contain the letters GEN:  
SELECT first_name, last_name
	FROM actor
    WHERE last_name LIKE'%GEN%';
    
    
# 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name
	FROM actor
    WHERE last_name LIKE'%LI%'
    ORDER BY last_name,first_name;
    
 
# Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
	WHERE country IN ('Afghanistan', 'Bangladesh','China');
    
# 3a You want to keep a description of each actor. No performing queries on a description, 
#     create a column in the table actor named description and use the data type BLOB
ALTER TABLE actor ADD COLUMN description blob not null;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
	DROP COLUMN description;
    
#4a List the last names of actors, as well as how many actors have that last name.
SELECT DISTINCT last_name, 
	COUNT(last_name) AS 'last_name_count' 
    FROM actor 
    GROUP BY last_name;
    
#4b List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) as "Last Name Count"
	FROM actor
	GROUP BY last_name
	HAVING COUNT(last_name) >=2;
    
#4c The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
	SET first_name = 'Harpo'
	WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO
UPDATE actor 
	SET first_name= 'GROUCHO'
	WHERE first_name='HARPO' AND last_name='WILLIAMS';
    
DESC address;
#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

CREATE TABLE IF NOT EXISTS
 `address` (
 `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
 `address` varchar(50) NOT NULL,
 `address2` varchar(50) DEFAULT NULL,
 `district` varchar(20) NOT NULL,
 `city_id` smallint(5) unsigned NOT NULL,
 `postal_code` varchar(10) DEFAULT NULL,
 `phone` varchar(20) NOT NULL,
 `location` geometry NOT NULL,
 `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 PRIMARY KEY (`address_id`),
 KEY `idx_fk_city_id` (`city_id`),
 SPATIAL KEY `idx_location` (`location`),
 CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;
  
# 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address
SELECT s.first_name, s.last_name, a.address
	FROM staff s 
    LEFT JOIN address a 
    ON s.address_id = a.address_id;
    
#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. 	
SELECT s.first_name, s.last_name, SUM(p.amount) AS August_Payments
	FROM staff s
	INNER JOIN payment p
	ON s.staff_id = p.staff_id
	WHERE p.payment_date LIKE '2005-08%'
	GROUP BY p.staff_id; 

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, COUNT(actor_id)
	FROM film f
	INNER JOIN film_actor fa
	ON f.film_id = fa.film_id
	GROUP BY title;
    
#  6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(inventory_id)
	FROM film f
	INNER JOIN inventory i 
	ON f.film_id = i.film_id
	WHERE title = "Hunchback Impossible";
  
#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#List the customers alphabetically by last name:
SELECT first_name, last_name,  SUM(amount) AS Total
	FROM payment p
	INNER JOIN customer c
	ON p.customer_id = c.customer_id
	GROUP BY p.customer_id
	ORDER BY last_name ASC;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting 
# with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies 
#starting with the letters K and Q whose language is English.
SELECT title FROM film
	WHERE language_id in
		(SELECT language_id 
		FROM language
		WHERE name = "English" )
	AND (title LIKE "K%") OR (title LIKE "Q%");

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
	FROM actor
	WHERE actor_id in
		(SELECT actor_id 
        FROM film_actor
		WHERE film_id in 
			(SELECT film_id 
            FROM film
			WHERE title = "Alone Trip"));
            
#7c. You want to run an email marketing campaign in Canada,  Use joins to retrieve this information.
#for which you will need the names and email addresses of all Canadian customers.
#Use joins to retrieve this information.
SELECT country, first_name,last_name, email
	FROM country c
	JOIN customer cr
	ON c.country_id = cr.customer_id
	WHERE country = 'Canada';
    
#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as family films.	    
SELECT title, category
	FROM film_list
	WHERE category = 'Family';		
    
#7e. Display the most frequently rented movies in descending order.
SELECT i.film_id, f.title, COUNT(r.inventory_id) AS Movies_Rented
	FROM inventory i
	INNER JOIN rental r
	ON i.inventory_id = r.inventory_id
	INNER JOIN film_text f 
	ON i.film_id = f.film_id
	GROUP BY r.inventory_id
	ORDER BY COUNT(r.inventory_id) DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT st.store_id, SUM(amount)
	FROM store st
	INNER JOIN staff sf
	ON st.store_id = sf.store_id
	INNER JOIN payment p 
	ON p.staff_id = sf.staff_id
	GROUP BY st.store_id
	ORDER BY SUM(amount);
    
#7g. Write a query to display for each store its store ID, city, and country. SELECT s.store_id, city, country
SELECT s.store_id, city, country
FROM store s
INNER JOIN customer cr
ON s.store_id = cr.store_id
INNER JOIN staff sf
ON s.store_id = sf.store_id
INNER JOIN address a
ON cr.address_id = a.address_id
INNER JOIN city ci
ON a.city_id = ci.city_id
INNER JOIN country cn
ON ci.country_id = cn.country_id;

#7h. List the top five genres in gross revenue in descending order.
SELECT name, SUM(p.amount) AS gross_revenue
	FROM category c
	INNER JOIN film_category fc
	ON fc.category_id = c.category_id
	INNER JOIN inventory i
	ON i.film_id = fc.film_id
	INNER JOIN rental r
	ON r.inventory_id = i.inventory_id
	INNER JOIN payment p
	ON p.rental_id = r.rental_id
	GROUP BY name
	ORDER BY gross_revenue DESC
	LIMIT 5;
    
#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution
#from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS

SELECT name, SUM(p.amount) AS gross_revenue
    FROM category c
	JOIN film_category fc
	ON fc.category_id = c.category_id
	JOIN inventory i 
    ON i.film_id = fc.film_id
	JOIN rental r
	ON r.inventory_id = i.inventory_id
	JOIN payment p 
    ON p.rental_id = r.rental_id
		GROUP BY name
		ORDER BY gross_revenue DESC
		LIMIT 5;
    
#8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;