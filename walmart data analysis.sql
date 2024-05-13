-- Data cleaning
-- SQL portfolio Project  - Data Cleaning
--  Kaggle Walmart Sales Forecasting Competition.

-- now when i'm doing data cleaning i usually follow a few steps
-- 1. check for duplicates and remove any duplicate
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

SELECT * 
FROM walmart_sales.`walmartsalesdata.csv`;

-- note, -- first thing I want to do is create a staging table. This is the one i will work on and clean the data. i want a table with the raw data in case something happens


--------------------------------------------------------------------------------------------------------------------------

--- Feature Engineering: This will help use generate some new columns from existing ones.
--- i want to add time_of_day;

select time,
(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END 
    ) AS time_of_day
FROM walmart_sales.`walmartsalesdata.csv`;

ALTER TABLE `walmartsalesdata.csv` ADD COLUMN time_of_day VARCHAR(20);

UPDATE `walmartsalesdata.csv`
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

------- 
-- Add day_name column
SELECT
	date,
	DAYNAME(date)
FROM `walmartsalesdata.csv`;

ALTER TABLE `walmartsalesdata.csv` ADD COLUMN day_name VARCHAR(10);

UPDATE `walmartsalesdata.csv`
SET day_name = DAYNAME(date);
---------------------------------------------------------------------------------------------------------------

-- Add month_name column
SELECT
	date,
	MONTHNAME(date)
FROM `walmartsalesdata.csv`;

ALTER TABLE`walmartsalesdata.csv` ADD COLUMN month_name VARCHAR(10);

UPDATE `walmartsalesdata.csv`
SET month_name = MONTHNAME(date);

-- --------------------------------------------------------------------
-- ---------------------------- Generic ------------------------------
-- --------------------------------------------------------------------
-- How many unique cities does the data have?

SELECT 
	DISTINCT City
FROM `walmartsalesdata.csv`;

-- In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM  `walmartsalesdata.csv`;

-- --------------------------------------------------------------------
-- ---------------------------- Product -------------------------------
-- --------------------------------------------------------------------

-- How many unique product lines does the data have?
SELECT `Product_line`
	  
FROM `walmartsalesdata.csv`;

-- What is the most selling product line
SELECT
	SUM(quantity) as qty,
    product_line
FROM `walmartsalesdata.csv`
GROUP BY product_line
ORDER BY qty DESC;

-- What is the most selling product line
SELECT
	SUM(quantity) as qty,
    product_line
FROM `walmartsalesdata.csv`
GROUP BY product_line
ORDER BY qty DESC;


-- What is the total revenue by month
SELECT
	month_name AS month,
	SUM(total) AS total_revenue
FROM `walmartsalesdata.csv`
GROUP BY month_name 
ORDER BY total_revenue;


-- What month had the largest COGS?
SELECT
	month_name AS month,
	sum(cogs) AS cogs
FROM `walmartsalesdata.csv`
GROUP BY month_name 
ORDER BY cogs;


-- What product line had the largest revenue?
SELECT
	product_line,
	SUM(total) as total_revenue
FROM `walmartsalesdata.csv`
GROUP BY product_line
ORDER BY total_revenue DESC;

------ What is the city with the largest revenue?
SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM `walmartsalesdata.csv`
GROUP BY city, branch 
ORDER BY total_revenue;


-- What product line had the largest VAT?
SELECT
	product_line,
	AVG(tax_pct) as avg_tax
FROM `walmartsalesdata.csv`
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM `walmartsalesdata.csv`
GROUP BY product_line;


-- Which branch sold more products than average product sold?
SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM `walmartsalesdata.csv`
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);


-- What is the most common product line by gender
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM `walmartsalesdata.csv`
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line
SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM `walmartsalesdata.csv`
GROUP BY product_line
ORDER BY avg_rating DESC;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT
DISTINCT customer_type
FROM `walmartsalesdata.csv`;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM `walmartsalesdata.csv`;

-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM `walmartsalesdata.csv`
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM  `walmartsalesdata.csv`
GROUP BY customer_type;

-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM `walmartsalesdata.csv`
GROUP BY gender
ORDER BY gender_cnt DESC;


-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM `walmartsalesdata.csv`
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM `walmartsalesdata.csv`
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM `walmartsalesdata.csv`
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.

-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM `walmartsalesdata.csv`
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?

-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM `walmartsalesdata.csv`
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday 

SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM `walmartsalesdata.csv`
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM`walmartsalesdata.csv`
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM `walmartsalesdata.csv`
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM `walmartsalesdata.csv`
GROUP BY customer_type
ORDER BY total_tax;



















