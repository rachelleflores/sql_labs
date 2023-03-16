# Lab | SQL Joins on multiple tables
USE sakila;

# 1. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store s
JOIN address a
USING (address_id)
JOIN city c1
USING (city_id)
JOIN country c2
USING (country_id);

# 2. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, CONCAT("$ ", SUM(amount)) total_revenue -- to show the total amount with the dollar sign in front
FROM store s1
RIGHT JOIN staff s2
USING (store_id)
RIGHT JOIN payment
USING (staff_id)
GROUP BY store_id;

# 3. What is the average running time of films by category?
DROP TABLE IF EXISTS duration_category;
CREATE TEMPORARY TABLE duration_category -- creating a temp table since there is another question relating to the same query after.
SELECT name category, ROUND(AVG(length),2) average_duration
FROM category c
JOIN film_category fc
USING (category_id)
JOIN film f
USING (film_id)
GROUP BY category;

SELECT *
FROM duration_category;

# 4. Which film categories are longest?
SELECT *
FROM duration_category
ORDER BY average_duration DESC;

# 5. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.rental_id) rental_count
FROM rental r
JOIN inventory i
USING (inventory_id)
JOIN film f
USING (film_id)
GROUP BY f.title
ORDER BY rental_count DESC;

# 6. List the top five genres in gross revenue in descending order.
SELECT name category, CONCAT("$ ", SUM(amount)) revenue_per_category
FROM payment p
JOIN rental r
USING (rental_id)
JOIN inventory i
USING (inventory_id)
JOIN film f
USING (film_id)
JOIN film_category fc
USING (film_id)
JOIN category c
USING (category_id)
GROUP BY category
ORDER BY revenue_per_category DESC;
-- Can I just say, I have never joined so much table until now 😳

# 7. Is "Academy Dinosaur" available for rent from Store 1?
SELECT i.store_id, f.title, COUNT(i.inventory_id) inventory_count
FROM inventory i
JOIN film f
USING (film_id)
WHERE title = "Academy Dinosaur" AND i.store_id = 1 
GROUP BY i.store_id, f.title; -- yes, there are 4 copies of this film in store 1's inventory.