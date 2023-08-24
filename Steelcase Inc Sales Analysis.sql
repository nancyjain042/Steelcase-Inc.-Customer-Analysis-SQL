CREATE DATABASE Portfolio;
USE Portfolio;

-- Data overview
SELECT TOP 3 *           --Dimension table
FROM master_customer;

SELECT TOP 3  *          --Dimension table
FROM master_product;

SELECT TOP 3  *          --Fact table
FROM store_data;


 
--Exploratory Data Analysis


--Geographical Analysis
--Que-1 What is the total sales for each product category in each region?
SELECT 
	c.Region,
	p.Category,
	SUM( s.Sales) AS Total_Sales 
FROM 
	store_data s 
JOIN
	master_customer c ON s.Customer_ID = c.Customer_ID
JOIN
	master_product p ON s.Product_ID = p.Product_ID
GROUP BY 
	c.Region, p.Category
ORDER BY
	c.Region,Total_Sales DESC


--Que-2 Which state contributes the most to the company's overall sales?
SELECT TOP 1
	c.State,
	SUM( s.Sales) AS Total_Sales 
FROM 
	store_data s 
JOIN
	master_customer c ON s.Customer_ID = c.Customer_ID
GROUP BY c.State
ORDER BY Total_Sales DESC 


--Que-3 Calculate the percentage distribution of each subcategory sales to the total sales in various region.
SELECT 
	c.Region,
	p.Sub_Category,
	(SUM( s.Sales)/(SELECT SUM(Sales) FROM store_data))*100 AS Percentage_Sales 
FROM 
	store_data s 
JOIN
	master_customer c ON s.Customer_ID = c.Customer_ID
JOIN
	master_product p ON s.Product_ID = p.Product_ID
GROUP BY 
	c.Region, p.Sub_Category
ORDER BY
	c.Region, Percentage_Sales DESC




--Market Segmentation Analysis
--Que-1 Are there any specific states where a particular segment dominates?
SELECT c.State,c.Segment, SUM(s.Sales) as Total_Sales
FROM master_customer c
JOIN 
	store_data s ON c.Customer_ID = s.Customer_ID
GROUP BY c.State, c.Segment
HAVING Count(State)<3
ORDER BY c.State, Total_Sales DESC


--Que-2 Which product categories are preferred by each customer segment?
WITH RankedSales AS (
    SELECT 
        c.Segment,
        p.Category,
        SUM(s.Sales) AS Total_Sales, 
        ROW_NUMBER() OVER(PARTITION BY c.Segment ORDER BY SUM(s.Sales) DESC) AS rn 
    FROM 
        store_data s 
    JOIN
        master_customer c ON s.Customer_ID = c.Customer_ID
    JOIN
        master_product p ON s.Product_ID = p.Product_ID
    GROUP BY 
        c.Segment, p.Category
)
SELECT Segment, Category, Total_Sales
FROM RankedSales
WHERE rn = 1;


--Que-3 What is the distribution of customers across different segments?
SELECT Segment, COUNT(*) as Total_Customers
FROM master_customer c
GROUP BY Segment


--Que 4 Identify the segment that has the highest average order value.
SELECT c.Segment, AVG(s.Sales) as Average_Sales
FROM master_customer c
JOIN 
	store_data s ON c.Customer_ID = s.Customer_ID
GROUP BY c.Segment
ORDER BY Average_Sales DESC




--Product Performance:
--Que-1 What are the top 5 best-selling products in terms of total sales?
SELECT TOP 5 p.Product_Name , SUM(s.Sales) as Total_Sales
FROM master_product p
JOIN 
	store_data s ON p.Product_ID = s.Product_ID
GROUP BY p.Product_Name
ORDER BY Total_Sales DESC


--Que-2 How do the sales of different sub-categories change over time?(yearwise)
SELECT  p.Sub_Category ,
		SUM(CASE WHEN YEAR(s.Order_Date) = 2015 THEN s.Sales END) AS '2015',
		SUM(CASE WHEN YEAR(s.Order_Date) = 2016 THEN s.Sales END) AS '2016',
		SUM(CASE WHEN YEAR(s.Order_Date) = 2017 THEN s.Sales END) AS '2017',
		SUM(CASE WHEN YEAR(s.Order_Date) = 2018 THEN s.Sales END) AS '2018'
FROM master_product p
JOIN 
	store_data s ON p.Product_ID = s.Product_ID
GROUP BY p.Sub_Category


--Que-3 For each product calculate the moving average of sales over the last three months.
SELECT
    p.product_name,
    AVG(s.Sales) OVER (
        PARTITION BY s.Product_ID
        ORDER BY YEAR(s.Order_Date), MONTH(s.Order_Date)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Moving_Average
FROM
    store_data s
JOIN
    master_product p ON s.Product_ID = p.Product_ID;





-- Customer Analysis
--Que-1 Retrieve the top 5 customers with the highest average discount (amounts)applied to their orders.
SELECT TOP 5 
	c.Customer_Name,
	AVG(s.Sales*(s.discount)/100) AS Average_sales_discount
FROM 
	master_customer c
JOIN
	store_data s ON c.Customer_ID = s.Customer_ID
GROUP BY c.Customer_Name
ORDER BY Average_sales_discount DESC


--Que-2 Provide a list of customers who have made purchases in all available sub categories of products.
SELECT c.Customer_Name
FROM
	master_customer c
JOIN
	store_data s ON c.Customer_ID = s.Customer_ID
JOIN
	master_product p ON s.Product_ID = p.Product_ID
GROUP BY
	c.Customer_Name
HAVING 
	COUNT(DISTINCT p.Sub_Category) = (SELECT 
								COUNT(DISTINCT Sub_Category) 
							 FROM 
								master_product




-- Sales performance
--Que-1 Calculate the year-over-year growth rate in sales revenue for each year in the dataset
WITH YearlySales AS (
    SELECT
        YEAR(Order_date) AS 'year',
        SUM(Sales) AS total,
        LAG(SUM(Sales)) OVER (ORDER BY YEAR(Order_date)) AS prev_total
    FROM
        store_data
    GROUP BY
        YEAR(Order_Date)
)
SELECT
    "Year",
    COALESCE(((total - prev_total) / prev_total) * 100,0) AS yoy_growth
FROM
    YearlySales;



--Supply Chain
--Que 1  Determine the average delivery time for each shipping mode. 
SELECT Ship_Mode,AVG(DATEDIFF(minute, order_date, ship_date) / 1440.0) AS average_delivery_time
FROM store_data
GROUP BY Ship_Mode






