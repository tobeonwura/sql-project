/*===========================================================================
						 PART TO WHOLE ANALYSIS

Pattern: 
	-	Analyze how an individual part is performing compared to the overall,
		allowing us to understand which category has the greatest 
		impact on the business.
	-	(target[measure]/total[measure]) * 100 by [dimension]

Question: 
	-	Which categories contribute the most to overall sales 
 ============================================================================
 */

WITH category_sales AS(
SELECT 
	category,
	SUM(sales_amount) AS total_sales
	FROM fact_sales f
	LEFT JOIN dim_products p
	ON f.product_key = p.product_key
	GROUP BY category
)

SELECT 
category,
total_sales,
SUM(total_sales) OVER() AS overall_sales,
ROUND((CAST(total_sales AS FLOAT) /SUM(total_sales) OVER())*100,2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;



