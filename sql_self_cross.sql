# Lab | SQL Self and cross join
USE sakila;

# 1. Get all pairs of actors that worked together.
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


# 2. Get all pairs of customers that have rented the same film more than 3 times.
# first query to check which customers (if any) have rented the same film 3 or more times
SELECT film_id, customer_id, COUNT(customer_id) times_rented
FROM inventory
JOIN rental r1
USING (inventory_id) 
GROUP BY film_id, customer_id
HAVING times_rented >= 3; 
-- There are 4 customers that have rented a specific film 3x. However, they are 4 different films so doing the cross join to find pairs who rented the SAME films at least 3 times will definitely have no result.

# to check
SELECT film_id, r1.customer_id, COUNT(r1.customer_id) times_rented1, r2.customer_id, COUNT(r2.customer_id) times_rented2
FROM inventory
JOIN rental r1
USING (inventory_id)
JOIN rental r2
USING (inventory_id)
GROUP BY film_id, r1.customer_id, r2.customer_id
HAVING times_rented1 > 3 AND times_rented2 > 3 ; -- true enough, no result.

# checking for times rented at least 2x
SELECT film_id, f.title, r1.customer_id, COUNT(r1.customer_id) times_rented1, r2.customer_id, COUNT(r2.customer_id) times_rented2
FROM inventory
JOIN rental r1
USING (inventory_id)
JOIN rental r2
USING (inventory_id)
JOIN film f
USING (film_id)
WHERE r1.customer_id < r2.customer_id -- filter out the duplicate pairs
GROUP BY film_id, r1.customer_id, r2.customer_id
HAVING times_rented1 >= 2  AND times_rented2 >= 2 ; -- Caddyshack Jedi is the only film rented twice by two different customers.

# 3. Get all possible pairs of actors and films.
-- Simply looking at the film ids and actor_ids
SELECT f.film_id, a.actor_id
FROM actor a
CROSS JOIN film f
ORDER BY film_id, actor_id;

-- more elaborate result with film title and actor names
SELECT f.film_id, f.title, a.actor_id, CONCAT(a.first_name, ' ', a.last_name) actor_name
FROM film f 
CROSS JOIN actor a
ORDER BY film_id, actor_id;

-- either way, is it safe to conclude that the result from finding ALL possible pairs of actors and films is just:
### 1000 films x 200 actors = film_id 1 paired with actors 1 to 200, ... and the same all the way to film_id 1000?