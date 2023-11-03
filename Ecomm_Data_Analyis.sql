-- ASSIGNMENT QUESTIONS FOR ANALYSIS

-- Create a temporary table that joins the orders, order_products, and products tables to get information about each order, including the products that were purchased and their department and aisle information.
CREATE TEMPORARY TABLE order_product_info AS
SELECT op.add_to_cart_order , op.reordered , op.order_id , o.order_number , p.product_id , 
o.order_dow , o.order_hour_of_day , o.days_since_prior_order , p.product_name , p.aisle_id , p.department_id
FROM order_products AS op
INNER JOIN orders AS o ON op.order_id = o.order_id
INNER JOIN products AS p ON op.product_id = p.product_id;

-- ANSWER : 
SELECT * FROM order_product_info;

-- Create a temporary table that groups the orders by product and finds the total number of times each product was purchased, the total number of times each product was reordered, and the average number of times each product was added to a cart.
CREATE TEMPORARY TABLE product_summary AS 
SELECT product_id , product_name , SUM(order_number)AS times_product_purchased , SUM(reordered) AS times_reordered, 
AVG(add_to_cart_order) AS times_add_to_cart 
FROM order_product_info
GROUP BY product_id,product_name;

-- ANSWER :
SELECT * FROM product_summary;

-- Create a temporary table that groups the orders by department and finds the total number of products purchased, the total number of unique products purchased, the total number of products purchased on weekdays vs weekends, and the average time of day that products in each department are ordered.
CREATE TEMPORARY TABLE product_dept_info AS
SELECT department_id , SUM(order_number) AS times_product_purchased , COUNT (DISTINCT order_number) AS unique_products_purchased , 
COUNT (CASE WHEN order_dow < 6 THEN 1 ELSE NULL END) AS weekday_orders,
COUNT(CASE WHEN order_dow >= 6 THEN  1 ELSE NULL END) AS weekend_orders , 
ROUND(AVG(order_hour_of_day), 0) AS avg_time_added 
FROM order_product_info
GROUP BY department_id;

-- ANSWER :
SELECT * FROM product_dept_info;

-- Create a temporary table that groups the orders by aisle and finds the top 10 most popular aisles, including the total number of products purchased and the total number of unique products purchased from each aisle.
CREATE TEMPORARY TABLE aisle_product_info AS 
SELECT aisle_id , COUNT(order_number) AS product_purchased , COUNT(DISTINCT order_number) AS unique_products_purchased  
FROM order_product_info
GROUP BY aisle_id
ORDER BY aisle_id desc 
LIMIT 10 ;

--ANSWER :
SELECT * FROM aisle_product_info;

-- Combine the information from the previous temporary tables into a final table that shows the product ID, product name, department ID, department name, aisle ID, aisle name, total number of times purchased, total number of times reordered, average number of times added to cart, total number of products purchased, total number of unique products purchased, total number of products purchased on weekdays, total number of products purchased on weekends, and average time of day products are ordered in each department.
CREATE TEMPORARY TABLE all_info AS 
SELECT products.product_id , products.product_name , products.department_id , aisles.aisle_id , aisles.aisle ,
ps.times_reordered , product_dept_info.avg_time_added ,  ps.times_product_purchased , product_dept_info.unique_products_purchased , 
product_dept_info.weekday_orders , product_dept_info.weekend_orders 
FROM product_summary AS ps
JOIN products ON ps.product_id = products.product_id
JOIN product_dept_info ON products.department_id = product_dept_info.department_id
JOIN aisles ON products.aisle_id = aisles.aisle_id
JOIN department ON products.department_id = department.department_id;

-- ANSWER : 
SELECT * FROM all_info;
