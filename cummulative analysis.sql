/*===========================================================================
			Cummulative Analysis
============================================================================*/

-- calculate the total sales per month
SELECT 
DATETRUNC(MONTH, order_date) AS order_month,
SUM(sales_amount) AS total_sales
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date);


-- running total and 3 day moving average of sales and 3 day moving average of price over time
SELECT order_date, total_sales,
SUM(total_sales) OVER( ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
AVG(total_sales) OVER( ORDER BY order_date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS moving_average_sales,
average_price, AVG(average_price) OVER( ORDER BY order_date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS moving_average_price
FROM(
	SELECT 
	DATETRUNC(MONTH, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS average_price
	FROM fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
) as table_new
ORDER BY order_date;


-- running total and 3 day moving average of sales, and 3 day moving average of price over time partitioned by year 
SELECT order_date, total_sales,
SUM(total_sales) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
AVG(total_sales) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS moving_average_sales,
average_price, AVG(average_price) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS moving_average_price
FROM(
	SELECT 
	DATETRUNC(MONTH, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS average_price
	FROM fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
) as table_new
ORDER BY order_date;