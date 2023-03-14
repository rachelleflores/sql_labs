# Lab: SQL Join
USE sakila;

# Instructions
# 1. List the number of films per category.
SELECT category_id, name, COUNT(film_id) as film_count
FROM film_category f
JOIN category c
USING (category_id)
GROUP BY category_id, name;

# 2. Display the first and the last names, as well as the address, of each staff member.
SELECT first_name, last_name, address
FROM staff
JOIN address
USING (address_id);

# 3. Display the total amount rung up by each staff member in August 2005.
SELECT staff_id, SUM(rental_id) as total_rentals
FROM rental
WHERE MONTH(rental_date) = 8
GROUP BY staff_id;

# 4. List all films and the number of actors who are listed for each film.
SELECT title, COUNT(actor_id) as total_actors_listed
FROM film
JOIN film_actor
USING (film_id)
GROUP BY title;

# 5. Using the payment and the customer tables as well as the JOIN command, list the total amount paid by each customer. 
-- List the customers alphabetically by their last names.
SELECT c.customer_id, first_name, last_name, SUM(amount) as total_payment
FROM customer c
JOIN payment p
USING (customer_id)
GROUP BY c.customer_id, first_name, last_name
ORDER BY last_name; -- default is ASC