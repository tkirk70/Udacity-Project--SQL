-- Submission October 28, 2021.

-- Set One Question 1 - Rentals by Family Friendly Genre.

SELECT /*f.title,*/ c.name AS category_name, COUNT(*)
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON c.category_id = fc.category_id
WHERE fc.category_id IN (SELECT DISTINCT(t1.category_id) AS family_friendly_ids
FROM
(SELECT f.title, fc.category_id, c.name
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
WHERE c.name IN
('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) t1)
GROUP BY 1
ORDER BY 1;

-- Formatted by: https://www.freeformatter.com/sql-formatter.html
SELECT
   /*f.title,*/
   c.name AS category_name,
   COUNT(*)
FROM
   film f
   JOIN
      inventory i
      ON f.film_id = i.film_id
   JOIN
      rental r
      ON r.inventory_id = i.inventory_id
   JOIN
      film_category fc
      ON f.film_id = fc.film_id
   JOIN
      category c 
      ON c.category_id = fc.category_id
WHERE
   fc.category_id IN
   (
      SELECT DISTINCT
(t1.category_id) AS family_friendly_ids
      FROM
         (
            SELECT
               f.title,
               fc.category_id,
               c.name
            FROM
               film f
               JOIN
                  film_category fc
                  ON f.film_id = fc.film_id
               JOIN
                  category c
                  ON fc.category_id = c.category_id
            WHERE
               c.name IN
               (
                  'Animation',
                  'Children',
                  'Classics',
                  'Comedy',
                  'Family',
                  'Music'
               )
         )
         t1
   )
GROUP BY
   1
ORDER BY
   1;
"category_name"	"count"
"Animation"	1166
"Children"	945
"Classics"	939
"Comedy"	941
"Family"	1096
"Music"	830

-- Set One Question 2 - Family Friendly Revenue by Gengre.
SELECT /*CASE WHEN c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
		THEN 'Family Friendly' ELSE 'Other Movies' END AS movie_group,*/
		c.name AS category, /*COUNT(r.rental_id) AS rentals,
		COUNT(DISTINCT i.inventory_id) AS videos_on_hand, COUNT(DISTINCT f.title) AS titles,*/
		SUM(p.amount) AS revenue,
		RANK() OVER (ORDER BY SUM(p.amount) DESC)
			FROM category c
			JOIN film_category fc
			ON c.category_id = fc.category_id
			JOIN film f
			ON f.film_id = fc.film_id
			JOIN inventory i
			ON i.film_id = f.film_id
			JOIN rental r
			ON r.inventory_id = i.inventory_id
			JOIN payment p
			ON p.rental_id = r.rental_id
			WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
			GROUP BY 1
			ORDER BY 2 DESC;
			"category"	"revenue"	"rank"
			"Animation"	4245.31	1
			"Comedy"	4002.48	2
			"Family"	3830.15	3
			"Classics"	3353.38	4
			"Children"	3309.39	5
			"Music"	3071.52	6


-- Set One Question 3 Family Friendly v Other revenue by rental
WITH t1 AS
	(SELECT c.name AS category, COUNT(r.rental_id) AS rentals,
	COUNT(DISTINCT i.inventory_id) AS videos_on_hand, COUNT(DISTINCT f.title) AS titles,
	SUM(p.amount) AS revenue
		FROM category c
		JOIN film_category fc
		ON c.category_id = fc.category_id
		JOIN film f
		ON f.film_id = fc.film_id
		JOIN inventory i
		ON i.film_id = f.film_id
		JOIN rental r
		ON r.inventory_id = i.inventory_id
		JOIN payment p
		ON p.rental_id = r.rental_id
	GROUP BY 1)
SELECT 'Family Friendly' AS movie_group, SUM(rentals) AS rentals,
SUM(videos_on_hand) AS videos_on_hand,
SUM(titles) AS titles, SUM(revenue) AS revenue,
TRUNC((SUM(revenue)/SUM(rentals)),2) AS revenue_per_rental,
TRUNC((SUM(revenue)/SUM(videos_on_hand)),2) AS revenue_per_videos_on_hand,
TRUNC((SUM(revenue)/SUM(titles)),2) AS revenue_per_title

FROM t1
WHERE category IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
UNION
SELECT 'Other Movies' AS movie_group, SUM(rentals) AS rentals,
SUM(videos_on_hand) AS videos_on_hand,
SUM(titles) AS titles, SUM(revenue) AS revenue,
TRUNC((SUM(revenue)/SUM(rentals)),2) AS revenue_per_rental,
TRUNC((SUM(revenue)/SUM(videos_on_hand)),2) AS revenue_per_videos_on_hand,
TRUNC((SUM(revenue)/SUM(titles)),2) AS revenue_per_title

FROM t1
WHERE category NOT IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music');
"movie_group"	"rentals"	"videos_on_hand"	"titles"	"revenue"	"revenue_per_rental"	"revenue_per_videos_on_hand"	"revenue_per_title"
"Family Friendly"	5375	1685	350	21812.23	4.05	12.94	62.32
"Other Movies"	9221	2895	608	39499.81	4.28	13.64	64.96

/*SET2Q1

We want to find out how the two stores compare in
their count of rental orders during every month for
all the years we have data for. Write a query that
returns the store ID for the store, the year and month
and the number of rental orders each store has
fulfilled for that month.
Your table should include a column for each
of the following:
year, month, store ID and count of rental orders fulfilled
during that month.*/

SELECT DATE_PART('month', rental_date) AS month_,
DATE_PART('year', rental_date) AS year_,
store_id, COUNT(*) AS monthly_rentals
FROM rental r
JOIN inventory i
ON i.inventory_id = r.inventory_id
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

/*SET2Q2

We would like to know who were our top 10
paying customers, how many payments they made
on a monthly basis during 2007, and what was
the amount of the monthly payments.
Can you write a query to capture the customer name,
month and year of payment, and total payment amount
for each month by these top 10 paying customers?*/

WITH top_10_paying AS
  (SELECT customer_id, SUM(amount) AS total_amt_paid
  FROM payment
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 10)
SELECT DATE_TRUNC('month', p.payment_date) AS pay_mon,
CONCAT(cus.first_name, ' ', cus.last_name), COUNT(*) AS pay_countpermon,
SUM(p.amount) AS pay_amount
FROM payment p
JOIN customer cus
ON p.customer_id = cus.customer_id
JOIN top_10_paying
ON top_10_paying.customer_id = cus.customer_id
WHERE p.customer_id IN (top_10_paying.customer_id)
GROUP BY 2, 1
ORDER BY 2;

/*SET2Q3

Finally, for each of these top 10 paying customers,
I would like to find out the difference across their
monthly payments during 2007. Please go ahead and write
a query to compare the payment amounts in each successive
month. Repeat this for each of these 10 paying customers.
Also, it will be tremendously helpful if you can identify
the customer name who paid the most difference in terms
of payments.*/

WITH top_10_paying AS
  (SELECT customer_id, SUM(amount) AS total_amt_paid
  FROM payment
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 10),
  top_10_by_month AS
  (SELECT DATE_TRUNC('month', p.payment_date) AS pay_mon,
  CONCAT(cus.first_name, ' ', cus.last_name) AS full_name,
  COUNT(*) AS pay_countpermon,
  SUM(p.amount) AS pay_amount
  FROM payment p
  JOIN customer cus
  ON p.customer_id = cus.customer_id
  JOIN top_10_paying
  ON top_10_paying.customer_id = cus.customer_id
  WHERE p.customer_id IN (top_10_paying.customer_id)
  GROUP BY 2, 1
  ORDER BY 2),
  add_lag AS
  (SELECT pay_mon, full_name, pay_amount,
  LAG(pay_amount) OVER (ORDER BY full_name) AS lag,
  pay_amount - LAG(pay_amount) OVER (ORDER BY full_name) AS difference
  FROM top_10_by_month)
SELECT full_name, pay_mon, difference
FROM add_lag
WHERE difference IS NOT NULL
ORDER BY difference DESC;
-- Not sure what code is wanted here.  Final answer or list.
