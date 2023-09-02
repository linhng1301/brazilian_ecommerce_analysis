-- Filling geolocation data
SELECT
	DISTINCT geolocation_zip_code_prefix,
	CASE
		WHEN geolocation_state IS NOT NULL THEN geolocation_state
		WHEN geolocation_zip_code_prefix BETWEEN 69900 AND 69999 THEN 'AC'
		WHEN geolocation_zip_code_prefix BETWEEN 57000 AND 57990 THEN 'AL'
		WHEN geolocation_zip_code_prefix BETWEEN 69000 AND 69290 OR geolocation_zip_code_prefix BETWEEN 69400 and 69890 THEN 'AM'
		WHEN geolocation_zip_code_prefix BETWEEN 68900 AND 68999 THEN 'AP'
		WHEN geolocation_zip_code_prefix BETWEEN 40000 AND 48990 THEN 'BA'
		WHEN geolocation_zip_code_prefix BETWEEN 60000 AND 63990 THEN 'CE'
		WHEN geolocation_zip_code_prefix BETWEEN 70000 AND 73690 THEN 'DF'
		WHEN geolocation_zip_code_prefix BETWEEN 29000 AND 29990 THEN 'ES'
		WHEN geolocation_zip_code_prefix BETWEEN 73700 AND 76790 THEN 'GO'
		WHEN geolocation_zip_code_prefix BETWEEN 65000 AND 65990 THEN 'MA'
		WHEN geolocation_zip_code_prefix BETWEEN 30000 AND 39990 THEN 'MG'
		WHEN geolocation_zip_code_prefix BETWEEN 79000 AND 79990 THEN 'MS'
		WHEN geolocation_zip_code_prefix BETWEEN 78000 AND 78890 THEN 'MT'
		WHEN geolocation_zip_code_prefix BETWEEN 66000 AND 68890 THEN 'PA'
		WHEN geolocation_zip_code_prefix BETWEEN 58000 AND 58990 THEN 'PB'
		WHEN geolocation_zip_code_prefix BETWEEN 50000 AND 56990 THEN 'PE'
		WHEN geolocation_zip_code_prefix BETWEEN 64000 AND 64990 THEN 'PI'
		WHEN geolocation_zip_code_prefix BETWEEN 80000 AND 86990 THEN 'PR'
		WHEN geolocation_zip_code_prefix BETWEEN 20000 AND 28990 THEN 'RJ'
		WHEN geolocation_zip_code_prefix BETWEEN 59000 AND 59990 THEN 'RN'
		WHEN geolocation_zip_code_prefix BETWEEN 76800 AND 76999 THEN 'RO'
		WHEN geolocation_zip_code_prefix BETWEEN 69300 AND 69399 THEN 'RR'
		WHEN geolocation_zip_code_prefix BETWEEN 90000 AND 99990 THEN 'RS'
		WHEN geolocation_zip_code_prefix BETWEEN 87000 AND 89990 THEN 'SC'
		WHEN geolocation_zip_code_prefix BETWEEN 49000 AND 49990 THEN 'SE'
		WHEN geolocation_zip_code_prefix BETWEEN 01000 AND 19990 THEN 'SP'
		WHEN geolocation_zip_code_prefix BETWEEN 77000 AND 77990 THEN 'TO'
		ELSE NULL
	END AS geolocation_state
INTO brazilian_zipcode_state
FROM olist_geolocation_dataset
ORDER BY geolocation_zip_code_prefix

SELECT *
FROM brazilian_zipcode_state
WHERE state_name IS NULL
ORDER BY geolocation_zip_code_prefix


UPDATE brazilian_zipcode_state
SET geolocation_state = 'PI'
WHERE geolocation_zip_code_prefix = 64995

DELETE FROM brazilian_zipcode_state
WHERE geolocation_zip_code_prefix = 80630 AND geolocation_state = 'SC'

UPDATE brazilian_zipcode_state
SET state_name = 'Tocantins' WHERE geolocation_state = 'TO'
UPDATE brazilian_zipcode_state
SET state_name = 'São Paulo' WHERE geolocation_state = 'SP'
UPDATE brazilian_zipcode_state
SET state_name = 'Sergipe' WHERE geolocation_state = 'SE'
UPDATE brazilian_zipcode_state
SET state_name = 'Santa Catarina' WHERE geolocation_state = 'SC'
UPDATE brazilian_zipcode_state
SET state_name = 'Rio de Janeiro' WHERE geolocation_state = 'RJ'
UPDATE brazilian_zipcode_state
SET state_name = 'Paraná' WHERE geolocation_state = 'PR'
UPDATE brazilian_zipcode_state
SET state_name = 'Piauí' WHERE geolocation_state = 'PI'


-- Looking at the number of order by state
SELECT
	states.state_name AS State,
	COUNT(orders.order_id) AS Number_of_order
FROM olist_orders_dataset AS orders
LEFT JOIN olist_customers_dataset AS customers ON orders.customer_id = customers.customer_id
LEFT JOIN brazilian_zipcode_state AS states ON customers.customer_zip_code_prefix = states.geolocation_zip_code_prefix
WHERE state_name IS NOT NULL
GROUP BY states.state_name
ORDER BY Number_of_order DESC

SELECT COUNT(order_id)
FROM olist_orders_dataset
-- Decribe the trend in total order by months of the year
SELECT
	FORMAT(order_approved_at,'MMM') AS Month
	,COUNT(order_id) AS Number_of_order
FROM olist_orders_dataset
GROUP BY FORMAT(order_approved_at,'MMM'), MONTH(order_approved_at)
ORDER BY MONTH(order_approved_at)

-- Looking at Time of the Day when orders were placed
-- Time of the Day: 0 - 5 (Dawn), 5-12 (Morning), 12 - 18 (Afternoon), 18 - 0 (Night)
SELECT
	CASE
		WHEN DATEPART(HOUR,order_approved_at) BETWEEN 0 AND 5 THEN 'Dawn'
		WHEN DATEPART(HOUR,order_approved_at) BETWEEN 5 AND 12 THEN 'Morning'
		WHEN DATEPART(HOUR,order_approved_at) BETWEEN 12 AND 18 THEN 'Afternoon'
		ELSE 'Night'
	END AS day_time
	,COUNT(order_id) AS Number_of_order
FROM olist_orders_dataset
GROUP BY
	CASE
		WHEN DATEPART(HOUR,order_approved_at) BETWEEN 0 AND 5 THEN 'Dawn'
		WHEN DATEPART(HOUR,order_approved_at) BETWEEN 5 AND 12 THEN 'Morning'
		WHEN DATEPART(HOUR,order_approved_at) BETWEEN 12 AND 18 THEN 'Afternoon'
		ELSE 'Night'
	END;

-- How many orders for each status?
SELECT
	order_status
	,COUNT(order_id) AS Number_of_order
FROM olist_orders_dataset
GROUP BY order_status

-- How customers are distributed in Brazil?
SELECT
	states.state_name,
	COUNT(customers.customer_id) AS Number_of_customer
FROM olist_customers_dataset AS customers
LEFT JOIN brazilian_zipcode_state AS states ON customers.customer_zip_code_prefix = states.geolocation_zip_code_prefix
GROUP BY states.state_name
ORDER BY Number_of_customer DESC

-- A comparison between 2017 and 2018 in revenue and number of order
SELECT
	YEAR(order_approved_at) AS Year
	,ROUND(SUM(price),2) AS revenue
	,COUNT(orders.order_id) AS number_of_order
FROM olist_order_items_dataset AS items
LEFT JOIN olist_orders_dataset AS orders ON items.order_id = orders.order_id
WHERE YEAR(order_approved_at) IN (2017,2018)
GROUP BY YEAR(order_approved_at)
-- How the total sales (sum of price) are concentraded in Brazilian states?
SELECT
	states.state_name
	,FLOOR(SUM(items.price)) AS total_sales
	,ROUND(AVG(items.price),2) AS avg_price
	,FLOOR(SUM(items.freight_value)) AS total_freight
	,ROUND(AVG(items.freight_value),2) AS avg_freight
FROM olist_order_items_dataset AS items
LEFT JOIN olist_orders_dataset AS orders ON orders.order_id = items.order_id
LEFT JOIN olist_customers_dataset AS customers ON orders.customer_id = customers.customer_id
LEFT JOIN brazilian_zipcode_state AS states ON customers.customer_zip_code_prefix = states.geolocation_zip_code_prefix
GROUP BY states.state_name
ORDER BY total_sales DESC

-- Delivery time vs estimated time by state
SELECT
	state_name
	,AVG(DATEDIFF(DAY,order_delivered_carrier_date,order_delivered_customer_date)) AS avg_delivery_time
	,AVG(DATEDIFF(DAY,order_delivered_carrier_date,order_estimated_delivery_date)) AS estimated_time
	,AVG(DATEDIFF(DAY,order_delivered_carrier_date,order_delivered_customer_date)) - AVG(DATEDIFF(DAY,order_delivered_carrier_date,order_estimated_delivery_date)) AS delivery_vs_estimated
FROM olist_orders_dataset AS orders
LEFT JOIN olist_customers_dataset AS customers ON orders.customer_id = customers.customer_id
LEFT JOIN brazilian_zipcode_state AS states ON customers.customer_zip_code_prefix = states.geolocation_zip_code_prefix
GROUP BY state_name
ORDER BY delivery_vs_estimated

-- Customer reflection about delivery quality
WITH temp AS (
SELECT
	review.review_id
	,review.review_score
	,review.review_comment_title
	,DATEDIFF(DAY,orders.order_purchase_timestamp,order_delivered_customer_date) AS delivery_day
FROM olist_order_reviews_dataset AS review
JOIN olist_orders_dataset AS orders ON review.order_id = orders.order_id
WHERE review.review_comment_title LIKE '%Entrega%'
)
SELECT
	review_score
	,COUNT(review_id) AS number_comment
FROM temp
GROUP BY review_score

-- Customer active percentage
SELECT
	COUNT(DISTINCT orders.customer_id)/COUNT(customer.customer_id)
FROM olist_orders_dataset AS orders
FULL OUTER JOIN olist_customers_dataset AS customer ON orders.customer_id = customer.customer_id


-- Number of order by product category
SELECT
	category.product_category_name_english,
	COUNT(items.order_id) AS number_of_order
FROM olist_order_items_dataset AS items
LEFT JOIN olist_products_dataset AS products ON items.product_id = products.product_id
LEFT JOIN product_category_name AS category ON products.product_category_name = category.product_category_name
GROUP BY category.product_category_name_english
ORDER BY number_of_order DESC

-- Decribe the trend of payment
SELECT
	payments.payment_type,
	COUNT(orders.order_id) AS number_of_order
FROM olist_orders_dataset AS orders
LEFT JOIN olist_order_payments_dataset AS payments ON orders.order_id = payments.order_id
GROUP BY payments.payment_type
ORDER BY number_of_order DESC

-- Number of order paid with payment installment
SELECT
	payment_installments
	,COUNT(order_id) AS number_of_order
FROM olist_order_payments_dataset
GROUP BY payment_installments
ORDER BY payment_installments