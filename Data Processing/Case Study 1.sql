SELECT *
FROM bright.coffee.shop_sales; 

SELECT *
FROM bright.coffee.shop_sales
LIMIT 10; 

-- Check all columns are in the correct format 
-- Check unit_price format: compare raw value, direct cast, and cleaned cast (comma to decimal point)
SELECT
     transaction_id,
     unit_price,
     TRY_CAST(unit_price AS DOUBLE) AS direct_cast,
     CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) AS unit_price_clean
FROM bright.coffee.shop_sales;

-- Remove rows with NULLs
SELECT *
FROM bright.coffee.shop_sales
WHERE unit_price IS NOT NULL;

-- Fill NULLs with a default value instead
SELECT
     transaction_id,
     COALESCE(CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2)), 0) AS unit_price_clean,
     COALESCE(product_category, 'Unknown') AS product_category
FROM bright.coffee.shop_sales;

-- Check number of records 
SELECT 
      COUNT(*)  AS total_records
FROM bright.coffee.shop_sales; 

-- If its columns then COUNT DISTINCT 
-- IF YOU GROUP BY A COLUMN THEN ALL COLUMNS SHOULD BE MENTIONED, so GROUP BY ALL is easier 
-- Check for duplicates  (It must be on a row-basis, and not column-basis) 
SELECT *, 
      COUNT(*) AS duplicate_count
FROM bright.coffee.shop_sales
GROUP BY ALL
HAVING COUNT(*) > 1; 

-- Check for NULL values 
SELECT *
FROM bright.coffee.shop_sales
WHERE transaction_id IS NULL OR transaction_date IS NULL OR transaction_time IS NULL OR transaction_qty IS NULL OR store_id IS NULL OR store_location IS NULL OR product_id IS NULL OR unit_price IS NULL OR product_category IS NULL OR product_type IS NULL OR product_detail IS NULL;  --NO NULL values

---------------------------------------------------------------------------------------------------------------------------------
-- 1. Total Revenue 
SELECT 
     SUM(transaction_qty * CAST(REPLACE(unit_price, ',','.') AS DOUBLE)) AS Total_amount
 FROM bright.coffee.shop_sales;     

-- 2 DECIMAL PLACES 
 SELECT 
     SUM(transaction_qty * CAST(REPLACE(unit_price, ',','.') AS DECIMAL (10,2))) AS Total_revenue
 FROM bright.coffee.shop_sales; 

-- 2. TOTAL REVENUE PER PRODUCT CATEGORY 
SELECT 
     product_category,
     SUM(transaction_qty * CAST(REPLACE(unit_price, ',','.') AS DECIMAL(10,2))) AS Total_revenue
 FROM bright.coffee.shop_sales
 GROUP BY ALL; -- GROUPING BY ALL is less tedious

-- Total revenue per transaction 
SELECT 
     transaction_id,
     SUM(transaction_qty * CAST(REPLACE(unit_price, ',','.') AS DECIMAL(10,2))) AS Total_revenue
 FROM bright.coffee.shop_sales
 GROUP BY ALL;

-- 3. TOTAL REVENUE PER PRODUCT CATEGORY & PRODUCT DETAILS 
SELECT 
     product_category, 
     SUM(transaction_qty * CAST(REPLACE(unit_price, ',','.') AS DECIMAL(10,2))) AS Total_revenue
FROM bright.coffee.shop_sales
GROUP BY ALL;

SELECT 
     product_category,
     product_detail,
     SUM(transaction_qty * CAST(REPLACE(unit_price, ',','.') AS DECIMAL(10,2))) AS Total_revenue
 FROM bright.coffee.shop_sales
 -- WHERE product_category = 'Tea' -- OR any other product category I prefer 
 GROUP BY ALL
 ORDER BY product_category; -- We can also ORDER BY Total_Revenue 

-- 4. TOTAL REVENUE PER PRODUCT TYPE 
SELECT 
     product_type, 
     SUM(transaction_qty * CAST(REPLACE(unit_price, ',','.') AS DECIMAL(10,2))) AS Total_revenue
 FROM bright.coffee.shop_sales
 GROUP BY ALL;

-- 5. TOTAL UNITS SOLD
SELECT 
     SUM(transaction_qty) AS Total_units_sold
 FROM bright.coffee.shop_sales;

-- 6. TOTAL REVENUE PER STORE LOCATION
SELECT                       
     store_location,
     SUM(transaction_qty * CAST(REPLACE(unit_price, ',','.') AS DECIMAL(10,2))) AS Total_revenue
 FROM bright.coffee.shop_sales
 GROUP BY ALL;

-- 7. TOTAL REVENUE BASED ON THE TIME OF THE DAY 
-- Earliest and latest transaction time 
SELECT  
     MIN(transaction_time),
     MAX(transaction_time)
FROM bright.coffee.shop_sales;

-- 6am - 11:59:59 > Morning 
-- 12pm - 16:59:59 > Afternoon 
-- 17pm - 19:59:59 > Evening 
-- After 20:00 > Night 

-- Bucket time with case statement
SELECT  
    -- transaction_time, -- we can't group the time bc it's always unique to a specific transcation
     -- product_category,
      CASE 
          WHEN transaction_time BETWEEN '06:00' AND '11:59:59' THEN 'Morning'
          WHEN transaction_time BETWEEN '12:00' AND '16:59:59' THEN 'Afternoon'
          WHEN transaction_time BETWEEN '17:00' AND '19:59:59' THEN 'Evening' 
          ELSE 'Night'
     END AS time_bucket,
SUM(transaction_qty * CAST(REPLACE(unit_price, ',','.') AS DECIMAL(10,2))) AS Total_revenue   
FROM bright.coffee.shop_sales
GROUP BY ALL;

-- Number of transactions per time bucket 
SELECT  
      CASE 
          WHEN transaction_time BETWEEN '06:00' AND '11:59:59' THEN 'Morning'
          WHEN transaction_time BETWEEN '12:00' AND '16:59:59' THEN 'Afternoon'
          WHEN transaction_time BETWEEN '17:00' AND '19:59:59' THEN 'Evening' 
          ELSE 'Night'
     END AS time_bucket,
COUNT(Transaction_id) AS Total_transactions
FROM bright.coffee.shop_sales
GROUP BY ALL;

-- 8. Date extraction (Month name, month_id, day name)
SELECT  
     transaction_date, 
     MONTHNAME(transaction_date) AS month_name,
     MONTH(transaction_date) AS month_number,
     DATE_FORMAT(transaction_date, 'yyyy-MMM') AS month_id,
     DAYNAME(transaction_date) AS day_name,
     DAYOFWEEK(transaction_date) AS day_number
FROM bright.coffee.shop_sales;

---------------------------------------------------------------------------------------------------------------------------------------

-- Practice: COMBINE ALL THE CODES
SELECT  
     transaction_id,
     transaction_date, 
     MONTHNAME(transaction_date) AS month_name,
     MONTH(transaction_date) AS month_number,
     DATE_FORMAT(transaction_date, 'yyyy-MMM') AS month_id,
     DAYNAME(transaction_date) AS day_name,
     DAYOFWEEK(transaction_date) AS day_number,
     product_category,
     product_type,
     product_detail,
     store_location,
      CASE 
          WHEN transaction_time BETWEEN '06:00' AND '11:59:59' THEN 'Morning'
          WHEN transaction_time BETWEEN '12:00' AND '16:59:59' THEN 'Afternoon'
          WHEN transaction_time BETWEEN '17:00' AND '19:59:59' THEN 'Evening' 
          ELSE 'Night'
     END AS time_bucket,
COUNT(Transaction_id) AS Total_transactions,
SUM(transaction_qty) AS Total_units_sold,
SUM(transaction_qty * CAST(REPLACE(unit_price, ',','.') AS DECIMAL(10,2))) AS Total_revenue   
FROM bright.coffee.shop_sales
GROUP BY ALL;

----------------------------------------------------------------------------------------------------------------------------------

-- Processed (Silver) table: cleaned price, total_amount, 30-min bucket, date parts
CREATE OR REPLACE TEMP VIEW bright_coffee_clean AS
SELECT
     transaction_id,
     transaction_date,
     transaction_time,
     MONTHNAME(transaction_date) AS month_name,
     MONTH(transaction_date) AS month_number,
     DAYNAME(transaction_date) AS day_name,
     DAYOFWEEK(transaction_date) AS day_number,
     store_id,
     store_location,
     product_id,
     product_category,
     product_type,
     product_detail,
     transaction_qty,
     CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2)) AS unit_price_clean,
     transaction_qty * CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2)) AS total_amount,
     CONCAT(
          LPAD(HOUR(TO_TIMESTAMP(transaction_time, 'HH:mm:ss')), 2, '0'), ':',
          CASE WHEN MINUTE(TO_TIMESTAMP(transaction_time, 'HH:mm:ss')) < 30 THEN '00' ELSE '30' END
     ) AS transaction_time_bucket,
     CASE
          WHEN transaction_time BETWEEN '06:00' AND '11:59:59' THEN 'Morning'
          WHEN transaction_time BETWEEN '12:00' AND '16:59:59' THEN 'Afternoon'
          WHEN transaction_time BETWEEN '17:00' AND '19:59:59' THEN 'Evening'
          ELSE 'Night'
     END AS time_of_day
FROM bright.coffee.shop_sales;

----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 9. Total revenue, units sold and transactions
SELECT 
     SUM(total_amount) AS total_revenue,
     SUM(transaction_qty) AS total_units,
     COUNT(transaction_id) AS total_transactions
FROM bright_coffee_clean;

-- 10. Best sellers (top 10 by revenue)
SELECT product_detail, 
     SUM(total_amount) AS revenue, SUM(transaction_qty) AS units_sold
FROM bright_coffee_clean
GROUP BY product_detail
ORDER BY revenue DESC
LIMIT 10;

-- 11. Lowest performers (bottom 10 by revenue)
SELECT product_detail, 
     SUM(total_amount) AS revenue, SUM(transaction_qty) AS units_sold
FROM bright_coffee_clean
GROUP BY product_detail
ORDER BY revenue ASC
LIMIT 10;

-- 12. Peak and slow 30-minute intervals (flip to ASC for slowest)
SELECT transaction_time_bucket,
       COUNT(transaction_id) AS total_transactions,
       SUM(transaction_qty) AS units_sold,
       SUM(total_amount) AS revenue
FROM bright_coffee_clean
GROUP BY transaction_time_bucket
ORDER BY revenue DESC;

-- 13. Revenue by time of day (Morning / Afternoon / Evening / Night)
SELECT time_of_day,
       COUNT(transaction_id) AS total_transactions,
       SUM(transaction_qty) AS units_sold,
       SUM(total_amount) AS revenue
FROM bright_coffee_clean
GROUP BY time_of_day
ORDER BY revenue DESC;

-- 14. Revenue trend by day of week (Sunday = 1)
SELECT day_name, day_number, 
     SUM(total_amount) AS revenue
FROM bright_coffee_clean
GROUP BY day_name, day_number
ORDER BY day_number;

-- 15. Revenue trend by month
SELECT month_name, month_number, 
     SUM(total_amount) AS revenue
FROM bright_coffee_clean
GROUP BY month_name, month_number
ORDER BY month_number;

-- 16. Revenue and units by store location
SELECT store_location, 
     SUM(transaction_qty) AS units_sold, SUM(total_amount) AS revenue
FROM bright_coffee_clean
GROUP BY store_location
ORDER BY revenue DESC;

-- 17. Revenue and units by product category
SELECT product_category, 
     SUM(transaction_qty) AS units_sold, SUM(total_amount) AS revenue
FROM bright_coffee_clean
GROUP BY product_category
ORDER BY revenue DESC;

-- 18. Revenue and units by product type
SELECT product_type, SUM(transaction_qty) AS units_sold, SUM(total_amount) AS revenue
FROM bright_coffee_clean
GROUP BY product_type
ORDER BY revenue DESC;

-- 19. EXPORT: processed dataset for Excel
SELECT *
FROM bright_coffee_clean
ORDER BY transaction_date, transaction_time;

