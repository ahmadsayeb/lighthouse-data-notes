-- Q1. Write a query to get Product name and quantity/unit.


-- Q2. Write a query to get most expense and least expensive Product list (name and unit price)


-- Q3. Write a query to count current and discontinued products.


-- Q4. Select all product names and their category names (77 rows)


-- Q5. Select all product names, unit price and the supplier region that don't have suppliers from USA region. (26 rows)


-- Q6. Get the total quantity of orders sold.( 51317)
SELECT SUM(order_details.quantity)
FROM order_details JOIN orders ON (order_details.orderid = orders.orderid);

-- Q7. Get the total quantity of orders sold for each order.(830 rows)
SELECT order_details.orderid,SUM(order_details.quantity)
FROM order_details JOIN orders ON (order_details.orderid = orders.orderid)
GROUP BY order_details.orderid;
-- Q8. Get the number of employees who have been working more than 5 year in the company. (9 rows)

SELECT COUNT(*) FROM Employees WHERE hiredate < '2015-09-21'
