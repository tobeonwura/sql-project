/*
============================================================================
Performance nalysis
============================================================================
Challenge: 
	- Analyze the yearly performance of products by comparing their sales
	to both the average sales performance and the the previuos year's sales 
 ===========================================================================
*/



WITH yearly_product_sales AS(
	SELECT 
		Year(f.order_date) AS order_year, 
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM fact_sales f 
	LEFT JOIN dim_products p 
	ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
	GROUP BY Year(f.order_date), p.product_name
) 


SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
CASE
	WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
	WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
	ELSE 'Avg'
END AS avg_change,

-- year-over-year analysis
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diif_py,
CASE
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	ELSE 'No Chabge'
END AS change_sales
FROM yearly_product_sales
ORDER BY product_name, order_year;
