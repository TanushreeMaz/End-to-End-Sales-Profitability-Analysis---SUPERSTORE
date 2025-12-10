use superstore;

/*Write a single query that returns the Customer ID and the Total Quantity of products they ordered, 
but only for the top 10 customers who ordered the highest total number of items (Quantity).*/
SELECT 
	Customer_ID,
    Product_Name,
    SUM(Quantity) AS Total_Quantity
FROM Orders
GROUP BY
	Customer_ID
ORDER BY
	Total_Quantity DESC
LIMIT 10;

/*Write a query that returns the Region, the Manager (Person from the people table), and the Total_Discount_Value (calculated as SUM(Sales∗Discount)). 
If a region has no manager in the people table, the Manager column should show 'Unassigned'.*/
SELECT
	o.Region,
	COALESCE(p.Person, 'Unassigned') AS People,
    SUM(Sales * Discount) AS Total_Discount_Value
FROM 
	Orders o
LEFT JOIN 
	People p 
ON
	o.Region = p.Region
GROUP BY
	o.Region,
    p.Person
ORDER BY
	Total_Discount_Value DESC;
    
/*Write the SQL code to create a Stored Procedure named Get_Region_Performance. 
This procedure should accept a single input parameter, region_name (VARCHAR), and return the Order ID, Total Sales, and Total Profit for that specific region.*/

/*Run Query to Check the Table*/
SELECT * FROM Orders;

/*Create Procedure*/
DELIMITER &&

CREATE PROCEDURE Get_Region_Performance(
IN input_region_name VARCHAR(50)
)
BEGIN
	SELECT 
		input_region_name AS Region_Name,
		SUM(Sales) AS Total_Sales,
		SUM(Profit) AS Total_Profit
	FROM
		Orders
	WHERE 
		Region = input_region_name;
END &&

DELIMITER &&

CALL Get_Region_Performance('West');
CALL Get_Region_Performance('Central');

/* Write the SQL code to create a View named V_Low_Profit_Tech_Orders. This view should contain all 
columns from orders_data but only for orders where the Category is 'Technology' and the Profit is less than 10.*/
CREATE VIEW V_Low_Profit_Tech_Orders AS
SELECT * FROM Orders
WHERE CATEGORY = 'Technology'
AND Profit < 10;

SELECT * FROM V_Low_Profit_Tech_Orders;

/* Regional Returns - Write a query to find the total number of orders returned
in each Region. The result should show the Region and the Total_Returns. */

SELECT 
	p.Region, 
	count(r.`Order ID`) as Total_Returns
from 
	Returns r
Inner Join 
	Orders o ON r.`Order ID`= o.Order_ID
Inner Join
	People p ON o.Region = p.Region
Group by 
	p.Region
Order by 
	Total_Returns DESC;

/*Profitability - Loss-Making Orders
Identifying and Analyzing Loss-Making Orders 
Which specific transactions generated the highest financial losses, and what factors 
(like discount rates) contributed to them?*/

SELECT
	Order_ID,
    Order_Date,
    Customer_Name,
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit_Loss,
    ROUND(AVG(Discount) * 100, 2) AS Avg_Dis_Percent
FROM
	Orders
WHERE
 Profit < 0
GROUP BY
	Order_ID,
    Order_Date,
    Customer_Name
    
ORDER BY
	Region,
	Total_Profit_Loss asc
LIMIT 10;
    
SELECT
    Order_ID,
    Order_Date,
    Customer_Name,
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit_Loss,
    -- Convert discount from 0.X to X% for clarity
    ROUND(AVG(Discount) * 100, 2) AS Average_Discount_Percent 
FROM
    Orders
WHERE
    Profit < 0
GROUP BY
    Order_ID,
    Order_Date,
    Customer_Name
    
ORDER BY
    Region ASC  -- ASC (Ascending) will put the largest negative numbers (worst losses) at the top
LIMIT 10;

/* MoM Sales Growth
Write a query to calculate the month-over-month sales growth percentage.
The result should show the Order_Month, Monthly_Sales, 
and the Sales_Growth_Percentage compared to the previous month. (Hint: Use LAG()).*/
WITH Monthly_Sales AS (
	SELECT 
		DATE_FORMAT(Order_Date, '%Y-%m') AS Order_Month,
        SUM(Sales) AS Monthly_Sales
	FROM
		Orders
	GROUP BY
		Order_Month
)
SELECT
	Order_Month,
	Monthly_Sales,
	LAG(Monthly_Sales, 1) OVER(ORDER BY Order_Month) AS Previous_Month_Sales,
	ROUND((Monthly_Sales - LAG(Monthly_Sales, 1) OVER(ORDER BY Order_Month))/
    LAG(Monthly_Sales, 1) OVER(ORDER BY Order_Month) * 100, 2) AS Sales_Growth_Percentage
	FROM
		Monthly_Sales
	ORDER BY
		Order_Month;
        
/*Product Ranking:
Assign a profit rank to every product sub-category for decision-making*/
SELECT
	Category,
	Sub_Category,
	SUM(Profit) AS Total_Profit,
	DENSE_RANK() OVER(ORDER BY SUM(Profit) DESC) AS Profit_Rank
FROM
	Orders
GROUP BY
	Category,
	Sub_Category
ORDER BY
	Profit_Rank;
/*Running Total of Profit by Region - Using a subquery, calculate the running total of Profit over all orders
 for each Region, ordered by Order Date. 
The result should show the Order ID, Region, Profit, and the Running_Total_Profit within that region.*/
SELECT
	t.Order_ID,
    t.Region,
    t.Profit,
    t.Running_Total_Profit_Region
FROM
	(
		SELECT
			Order_ID,
			Region,
            Profit,
			SUM(Profit) OVER(partition by Region Order by Order_Date) AS Running_Total_Profit_Region
		FROM
			Orders
	) AS t
Order BY t.Region, t.Order_ID;


































































































