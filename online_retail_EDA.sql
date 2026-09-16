DROP TABLE IF EXISTS ONLINE_RETAIL_EDA;

CREATE TABLE online_retail_EDA AS
SELECT *
FROM online_retail_clean;

SELECT *
FROM online_retail_EDA;

/*Phase 1: Revenue & Product Drivers
1. Executive Sales Summary
What is the business's total gross sales, 
total net revenue (accounting for returns), 
total volume of items sold, and total order count?*/

SELECT
	--calculating gross sales
	SUM(CASE WHEN transaction_type='SALE' THEN (price*quantity)
			ELSE 0
		END )AS gross_sales,
	--calculating return sales
	SUM(CASE WHEN transaction_type='RETURN' THEN (price*quantity)
			ELSE 0
		END )AS return_sales,
	--calulating total revenue
	SUM(price*quantity) AS total_revenue,
	--calculating total orders
	COUNT(DISTINCT (invoice)) AS total_orders,
	--Total units sold
	SUM(quantity) AS total_orders_sold
FROM online_retail_EDA;


/*Top 10 Revenue Generating Products
Which 10 products generate the highest net revenue,
and how many units were sold for each?*/

SELECT description,SUM(price*quantity) AS total_revenue,
SUM(quantity) AS total_units_sold
FROM online_retail_EDA
GROUP BY description
ORDER BY total_revenue DESC
LIMIT(10);

/*Phase 2: Customer Behavior & Segmentation
3. Guest vs. Registered Customer Revenue Split
What percentage of total sales volume and total revenue comes 
from registered customers versus unregistered 'Guest' checkouts?*/

SELECT CASE 
        WHEN customer_id = 'Guest' THEN 'Guest'
        ELSE 'Registered'
    END AS customer_type, SUM(price*quantity) AS total_revenue,
SUM(quantity) AS Total_sales_volume, ROUND((SUM(price*quantity)/SUM(SUM(price*quantity))OVER())*100,2) AS revenue_percentage,
ROUND((SUM(quantity) / SUM(SUM(quantity)) OVER()) * 100,2) AS sales_volume_percentage
FROM online_retail_EDA
GROUP BY 
    CASE 
        WHEN customer_id = 'Guest' THEN 'Guest'
        ELSE 'Registered'
    END;

/*4. Customer Lifetime Value (CLV) Top Performers
Who are the top 10 highest-spending registered customers,
how many distinct orders did they place, 
and what is their average order value (AOV)?*/

SELECT customer_id,
	SUM(price*quantity) AS total_revenue,
	COUNT(DISTINCT (invoice)) AS total_orders,
	ROUND(SUM(price*quantity)/COUNT(DISTINCT (invoice)),2) AS AOV
FROM online_retail_EDA
GROUP BY customer_id
HAVING customer_id<>'Guest'
ORDER BY total_revenue DESC
LIMIT(10);

/*Phase 3: Advanced Portfolio Showcase (Window Functions)
5. Monthly Revenue Growth & Trend Analysis
What is the total net revenue for each month,
and what is the month-over-month growth rate?*/
WITH cte AS (
	SELECT DATE_TRUNC('month', invoicedate)::DATE AS sales_month,
			SUM(price*quantity) AS total_revenue
	FROM online_retail_EDA
	GROUP BY DATE_TRUNC('month', invoicedate)::DATE)
SELECT sales_month,total_revenue, 
LAG(total_revenue,1) OVER(ORDER BY sales_month) AS previous_month_sales,
ROUND(((total_revenue-LAG(total_revenue,1) OVER(ORDER BY sales_month))/LAG(total_revenue,1) OVER(ORDER BY sales_month))*100,2) AS MOM
FROM cte
ORDER BY Sales_month ;

		
