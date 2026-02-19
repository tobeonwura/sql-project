/*===========================================================================
			Data Segmentation

	Segment products into cost ranges and count how many products fall 
	into each segment 
============================================================================*/

WITH product_segment AS(
	SELECT
	product_key,
	product_name,
	cost,
	CASE
		WHEN cost < 100 THEN 'Below 100'
		WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'Above 1000'
	END AS cost_range
	FROM dim_products
)

SELECT
cost_range,
COUNT(product_key) AS total_products
FROM product_segment
GROUP BY cost_range;




/* Group customers into three segments based on their spending behaviour:
	- VIP: Custormers with at least 12 months of history and spending more than $5,000.
	- Regular: Customers with at least 12 months of history but spending $5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

WITH customer_spending AS(
	SELECT
	c.customer_key,
	SUM(f.sales_amount) AS total_spending,
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
	FROM fact_sales f
	LEFT JOIN dim_customers c
	ON f.customer_key = c.customer_key
	GROUP BY c.customer_key
),

customer_segmentation AS(
	SELECT 
	customer_key, total_spending, lifespan,
	CASE
		WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment
	FROM customer_spending
)

SELECT 
customer_segment,
COUNT(*) AS total_customer
FROM customer_segmentation
GROUP BY customer_segment
ORDER BY COUNT(*) DESC;
