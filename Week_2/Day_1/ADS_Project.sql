

DROP TABLE if exists end_obs_dates;
CREATE TABLE end_obs_dates
AS

-- Recursive query example (something like FOR loop for SQL)
WITH RECURSIVE
  cnt(x) AS (
     SELECT 0
     UNION ALL
     SELECT x+1 FROM cnt
      LIMIT (SELECT ROUND(((julianday('1998-06-01') - julianday('1996-08-01'))/30) + 1)) -- this counts number of months between these two days
  )
SELECT date('1996-08-01', '+' || x || ' month') as end_obs_date FROM cnt;
DROP TABLE if exists ads_population_hist;

CREATE TABLE ads_population_hist
AS
SELECT A.*,
       B.*
FROM end_obs_dates AS A
CROSS JOIN (SELECT DISTINCT customerid FROM customers) AS B;


SELECT *,
       unitprice*quantity AS totalprice_for_product
FROM "Order Details" LIMIT 20;

SELECT A.orderid,
     COUNT(DISTINCT A.productid) AS no_of_distinct_products,
     SUM(A.quantity) AS no_of_items,
     SUM(A.totalprice_for_product) AS total_price
     FROM (SELECT *,
                  unitprice*quantity AS totalprice_for_product
           FROM "Order Details") AS A
GROUP BY 1;


select * from ads_population_hist limit 10;


SELECT
    orderid,
    customerid,
    orderdate
FROM orders
LIMIT 100;

SELECT orderid,
       customerid,
       orderdate,
       date(orderdate,'start of month','+1 month') as end_obs_date
FROM orders LIMIT 100;


DROP TABLE if exists ads_orders_hist;

CREATE TABLE ads_orders_hist
AS
SELECT A.orderid,
       A.customerid,
       A.end_obs_date,
       B.no_of_distinct_products,
       B.no_of_items,
       B.total_price
FROM (
    SELECT orderid,
             customerid,
             orderdate,
             date(orderdate,'start of month','+1 month') as end_obs_date
    FROM orders)
AS A
LEFT OUTER JOIN (
    SELECT A.orderid,
         COUNT(DISTINCT A.productid) AS no_of_distinct_products,
         SUM(A.quantity) AS no_of_items,
         SUM(A.totalprice_for_product) AS total_price
    FROM (
        SELECT *,
            unitprice*quantity AS totalprice_for_product
        FROM "Order Details")
    AS A
    GROUP BY 1)
AS B
ON A.orderid = B.orderid;

select * FROM ads_orders_hist LIMIT 10;


select orderid
    ,count(*)
from ads_orders_hist
group by 1
order by 2 desc
limit 5;


drop table if exists ads_observation_hist;
create table ads_observation_hist as
select
    A.*
    -- we can replace missings with 0 because it means there were no orders for this client during specific month.
    ,coalesce(B.no_of_distinct_orders_1M, 0) as no_of_distinct_orders_1M
    ,coalesce(B.no_of_items_1M, 0) as no_of_items_1M
    ,coalesce(B.total_price_1M, 0) as total_price_1M
from ads_population_hist as A
left outer join (
    -- we need to group by our orders to customer level
    select customerid
        ,end_obs_date
        ,count(distinct orderid) as no_of_distinct_orders_1M
        ,sum(no_of_items) as no_of_items_1M
        ,sum(total_price) as total_price_1M
    from ads_orders_hist
    group by 1,2
) as B
on A.customerid = B.customerid
  and A.end_obs_date = B.end_obs_date;

select customerid
    ,end_obs_date
    ,count(*)
from ads_observation_hist
group by 1,2
order by 3 desc
limit 5;


select * from ads_observation_hist;

SELECT end_obs_date, customerid,
       RANK() OVER (PARTITION BY end_obs_date) as noofitems_3M
       FROM ads_observation_hist;



