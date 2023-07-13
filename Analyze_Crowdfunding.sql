-- Dataset
-- https://mavenanalytics.io/challenges/maven-crowdfunding-challenge/15

-- Data Preparation
SELECT
    COUNT(*)
FROM
    crowdfunding;
	
SELECT
    *
FROM
    crowdfunding
LIMIT 100;

-- Convert the first letter of each word to upper case and the remaining to lower case.
UPDATE crowdfunding
SET "Name" = INITCAP("Name");

-- Use REGEXP_REPLACE to remove all non-alphanumeric characters and extra spaces in the string by replacing them with an empty string.
UPDATE crowdfunding
SET "Name" = REGEXP_REPLACE("Name", '[^a-zA-Z0-9 ]', '', 'g')
WHERE "Name" ~ '[^a-zA-Z0-9 ]';

-- Change the data type of the Id column from integer to varchar.
ALTER TABLE crowdfunding
ALTER COLUMN "Id" TYPE varchar;

-- Checks whether the data type of the Id column has been changed or not.
SELECT data_type
FROM information_schema.columns
WHERE table_name = 'crowdfunding' AND column_name = 'Id';

-- Using LPAD() is used to fill a string of a certain length with substrings.
UPDATE crowdfunding
SET "Id" = LPAD("Id", 10, '0');

SELECT
    *
FROM
    crowdfunding;

-- Check duplicate data
SELECT
	"Id",
	COUNT(*) AS dup_id
FROM
	crowdfunding
GROUP BY 1	
HAVING
	COUNT(*) > 1;

-- Check null value
SELECT 
	*
FROM 
	crowdfunding
WHERE 
	NULL IN ("Id", "Name", "Category", "Subcategory", "Country", "Launched", "Deadline", "Goal", "Pledged", "Backers", "State");


/* Exploratory Data Analysis*/

-- Descriptive Statistics
SELECT
	COUNT("Goal") AS count_goal,
	AVG("Goal") AS average_goal,
	SUM("Goal") AS sum_of_goal,
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY "Goal") AS first_quartile_goal,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Goal") AS median_goal,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY "Goal") AS third_quartile_goal,
	MAX("Goal") AS max_goal,
	MIN("Goal") AS min_goal,
	STDDEV("Goal") AS std_dev_goal
FROM
	crowdfunding;

SELECT
	COUNT("Pledged") AS count_pledged,
	AVG("Pledged") AS average_pledged,
	SUM("Pledged") AS sum_of_pledged,
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY "Pledged") AS first_quartile_pledged,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Pledged") AS median_pledged,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY "Pledged") AS third_quartile_pledged,
	MAX("Pledged") AS max_pledged,
	MIN("Pledged") AS min_pledged,
	STDDEV("Pledged") AS std_dev_pledged
FROM
	crowdfunding;
	
SELECT
	COUNT("Backers") AS count_backers,
	AVG("Backers") AS average_backers,
	SUM("Backers") AS sum_of_backers,
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY "Backers") AS first_quartile_backers,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Backers") AS median_backers,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY "Backers") AS third_quartile_backers,
	MAX("Backers") AS max_backers,
	MIN("Backers") AS min_backers,
	STDDEV("Backers") AS std_dev_backers
FROM
	crowdfunding;

-- Value Without Duplicates
SELECT
	DISTINCT("Category") AS unique_cat
FROM
	crowdfunding;

SELECT
	DISTINCT("Subcategory") AS unique_subcat
FROM
	crowdfunding;
	
SELECT
	DISTINCT("Country") AS unique_country
FROM
	crowdfunding;
	
SELECT
	DISTINCT("State") AS unique_state
FROM
	crowdfunding;
	
-- Average Number of Backers In Each Category With Success And Failed Projects
SELECT
	"Category",
	ROUND(AVG("Backers")) AS avg_backers
FROM
	crowdfunding
WHERE
	"State" = 'Successful' AND
	EXTRACT(YEAR FROM "Launched") BETWEEN 2010 AND 2017
GROUP BY 1
ORDER BY 2 DESC;

SELECT
	"Category",
	ROUND(AVG("Backers")) AS avg_backers
FROM
	crowdfunding
WHERE
	"State" = 'Failed' AND
	EXTRACT(YEAR FROM "Launched") BETWEEN 2010 AND 2017
GROUP BY 1
ORDER BY 2 DESC;

-- Total Backers Each Years
SELECT 
	EXTRACT(YEAR FROM "Launched") AS launch_year,
	SUM("Backers") AS total_backers
FROM 
	crowdfunding
WHERE
	EXTRACT(YEAR FROM "Launched") BETWEEN 2010 AND 2017
GROUP BY 1
ORDER BY 1;
	
-- Project Launch Trends In Each Category From Year To Year
SELECT
	EXTRACT(YEAR FROM "Launched") AS launch_yar,
	COUNT(*) AS num_of_project
FROM
	crowdfunding
WHERE
	EXTRACT(YEAR FROM "Launched") BETWEEN 2010 AND 2017
GROUP BY 1
ORDER BY 1;

/* In-depth Analysis of The Category Column */

-- Top 5 Number of Crowdfunding Projects by Categories Overall
SELECT
	"Category",
	COUNT("Category") AS number_of_cat
FROM
	crowdfunding
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Number of Crowdfunding Successful, Failed, Live, Canceled, & Suspended Projects by Categories
SELECT
	"Category",
	COUNT("Category") AS number_of_cat_success
FROM
	crowdfunding
WHERE
	"State" = 'Successful'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

SELECT
	"Category",
	COUNT("Category") AS number_of_cat_failed
FROM
	crowdfunding
WHERE
	"State" = 'Failed'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

SELECT
	"Category",
	COUNT("Category") AS number_of_cat_canceled
FROM
	crowdfunding
WHERE
	"State" = 'Canceled' AND
	EXTRACT(YEAR FROM "Launched") BETWEEN 2010 AND 2017
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

SELECT
	"Category",
	COUNT("Category") AS number_of_cat_suspended
FROM
	crowdfunding
WHERE
	"State" = 'Suspended' AND
	EXTRACT(YEAR FROM "Launched") BETWEEN 2010 AND 2017
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

SELECT
	"Category",
	COUNT("Category") AS number_of_cat_live
FROM
	crowdfunding
WHERE
	"State" = 'Live' AND
	EXTRACT(YEAR FROM "Launched") BETWEEN 2010 AND 2017
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Total of Crowdfunding Projects By Category And State
SELECT
	"Category",
	COUNT(*) AS total_projects,
	SUM(CASE WHEN "State" = 'Successful' THEN 1 ELSE 0 END) AS successful_projects,
	SUM(CASE WHEN "State" = 'Failed' THEN 1 ELSE 0 END) AS failed_projects,
	SUM(CASE WHEN "State" = 'Canceled' THEN 1 ELSE 0 END) AS canceled_projects,
	SUM(CASE WHEN "State" = 'Suspended' THEN 1 ELSE 0 END) AS suspended_projects,
	SUM(CASE WHEN "State" = 'Live' THEN 1 ELSE 0 END) AS live_projects
FROM
	crowdfunding
WHERE
	EXTRACT(YEAR FROM "Launched") BETWEEN 2010 AND 2017
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Percentage of Success and Failed Projects
WITH success AS (
SELECT
	"Category",
	COUNT(*) AS total_projects,
	SUM(CASE WHEN "State" = 'Successful' THEN 1 ELSE 0 END) AS successful_projects,
	ROUND(SUM(CASE WHEN "State" = 'Successful' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate
FROM
	crowdfunding
WHERE
	EXTRACT(YEAR FROM "Launched") BETWEEN 2010 AND 2017
GROUP BY 1
),
failed AS (
SELECT
	"Category",
	COUNT(*) AS total_projects,
	SUM(CASE WHEN "State" = 'Failed' THEN 1 ELSE 0 END) AS failed_projects,
	ROUND(SUM(CASE WHEN "State" = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS failed_rate
FROM
	crowdfunding
WHERE
	EXTRACT(YEAR FROM "Launched") BETWEEN 2010 AND 2017
GROUP BY 1
)
SELECT
	s."Category",
	s."success_rate",
	f."failed_rate"
FROM
	success AS s
JOIN
	failed AS f
ON s."Category" = f."Category"
ORDER BY 2 DESC;

-- Total Total percentage of successful projects
SELECT
    ROUND((COUNT(*) FILTER (WHERE "State" = 'Successful' AND EXTRACT(YEAR FROM "Launched") BETWEEN 2010 AND 2017) * 100.0 / COUNT(*)), 2) AS success_percentage
FROM
    crowdfunding;
	
SELECT
    ROUND((COUNT(*) FILTER (WHERE "State" = 'Failed' AND EXTRACT(YEAR FROM "Launched") BETWEEN 2010 AND 2017) * 100.0 / COUNT(*)), 2) AS failed_percentage
FROM
    crowdfunding;

