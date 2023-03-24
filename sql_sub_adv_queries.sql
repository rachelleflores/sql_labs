# Lab | SQL Subqueries
USE sakila;
-- Create appropriate joins wherever necessary.
# 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id) AS film_inventory
FROM inventory
WHERE film_id = (
				SELECT film_id
                FROM film
                WHERE title = 'Hunchback Impossible'
                ); 

# 2. List all films whose length is longer than the average of all the films.
SELECT title, length
FROM film
WHERE length > (
				SELECT AVG(length) AS avg_duration
				FROM film
                )
ORDER BY length DESC;

# 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id IN (	SELECT actor_id
                    FROM film_actor
                    WHERE film_id = (	SELECT film_id
										FROM film
										WHERE title = 'Alone Trip')
					);

# 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
# Check categories to verify the genre for family films
SELECT *
FROM category; -- category_id 8 = Family

# List of films in the family category
SELECT film_id, f.title
FROM film_category fc
JOIN film f
USING (film_id)
WHERE category_id = (	SELECT category_id
						FROM category
						WHERE name = 'Family');

# 5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
# Using subqueries
SELECT CONCAT(first_name, ' ', last_name) AS name
FROM customer
WHERE address_id IN (SELECT address_id
					FROM address 
					WHERE city_id IN (SELECT city_id
										FROM city
										WHERE country_id IN (SELECT country_id
															FROM country
															WHERE country = 'Canada')));

# Using joins
SELECT CONCAT(first_name, ' ', last_name) AS name, co.country
FROM customer cu
JOIN address 
USING (address_id)
JOIN city ci
USING (city_id)
JOIN country co
USING (country_id)
WHERE country = 'Canada';

# 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
WITH prolific_actor AS (
SELECT actor_id, COUNT(film_id) as films_starring
FROM film_actor
GROUP BY actor_id
ORDER BY films_starring DESC
LIMIT 1) -- cte to find the actor_id of the most prolific actor (answer: actor 107), used to filter the query
SELECT title
FROM film
WHERE film_id IN (	SELECT film_id
					FROM film_actor
                    WHERE actor_id = (SELECT actor_id FROM prolific_actor));

# 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments.

WITH 
best_customer AS (
SELECT customer_id, SUM(amount) as total_payment
FROM payment
GROUP BY customer_id
ORDER BY total_payment DESC
LIMIT 1), -- first cte to find best customer
film_list AS (
SELECT title, inventory_id, rental_id, customer_id
FROM film f
JOIN inventory i 
USING (film_id)
JOIN rental r
USING (inventory_id)) -- second cte to join film, inventory and rental tables. 
# If I understand it correctly, cte is kind of a variable in python which we can use as an alias to make the query cleaner and easier to read?
SELECT title
FROM film_list
WHERE customer_id IN (SELECT customer_id FROM best_customer);

# 8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
WITH cte_payment_per_client AS (
SELECT customer_id, SUM(amount) as total_payment
FROM payment
GROUP BY customer_id) -- query to get total amount spent by each customer, this will be used to get the average total payment per customer in the next query
SELECT *
FROM cte_payment_per_client
HAVING total_payment > (	SELECT AVG(total_payment) AS avg_payment 
							FROM cte_payment_per_client)
ORDER BY total_payment DESC;

# Lab | SQL Advanced queries
# 1. List each pair of actors that have worked together. -- copied from previous lab
SELECT film_id, f1.actor_id actor1, a1.first_name, a1.last_name, f2.actor_id actor2, a2.first_name, a2.last_name
FROM film_actor f1
JOIN actor a1
ON f1.actor_id = a1.actor_id
JOIN film_actor f2
USING (film_id)
JOIN actor a2
ON f2.actor_id = a2.actor_id
WHERE f1.actor_id < f2.actor_id -- to remove duplicate pairs
ORDER BY film_id;

# 2. For each film, list actor that has acted in more films.
WITH film_starring AS (
SELECT actor_id, COUNT(film_id) as film_count
FROM film_actor
GROUP BY actor_id
HAVING film_count > 1)
SELECT film_id, title, CONCAT(a.first_name, ' ', a.last_name) as actor_name
FROM film f
JOIN film_actor fa
USING (film_id)
JOIN actor a
USING (actor_id)
WHERE actor_id IN (	SELECT actor_id
					FROM film_starring)
ORDER BY film_id; -- to order result by film instead of actor name
                    
