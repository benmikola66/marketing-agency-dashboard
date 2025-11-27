/* ============================================================
   Opportunities Staging Cleanup Script
   - Inspect staging table
   - Check duplicates
   - Clean user_email
   - Standardize text fields (trade, stage)
   - Convert date and numeric columns
   ============================================================ */

---------------------------------------------------------------
-- 1. Inspect staging table and schema
---------------------------------------------------------------
SELECT * 
FROM opportunities_stg;

EXEC sp_help 'opportunities_stg';


---------------------------------------------------------------
-- 2. Basic counts and checks
---------------------------------------------------------------
-- Count distinct leads
SELECT COUNT(DISTINCT lead_id) 
FROM opportunities_stg;

-- Count Closed Won opportunities
SELECT COUNT(*)
FROM opportunities_stg
WHERE stage = 'closed won';


---------------------------------------------------------------
-- 3. Check duplicate leads
---------------------------------------------------------------
SELECT *
FROM opportunities_stg
WHERE lead_id IN (
	SELECT lead_id
	FROM opportunities_stg
	GROUP BY lead_id
	HAVING COUNT(*) > 1
);


---------------------------------------------------------------
-- 4. Clean user_email
---------------------------------------------------------------
-- If email is invalid, contains spaces, NULL, or too short,
-- append ".com" as a quick fix
UPDATE opportunities_stg
SET user_email = user_email + '.com' 
WHERE 
    user_email NOT LIKE '_%@_%._%'     
    OR user_email LIKE '% %'                           
    OR user_email IS NULL                   
    OR LEN(user_email) < 5;


---------------------------------------------------------------
-- 5. Convert lead_datetime to DATE
---------------------------------------------------------------
ALTER TABLE opportunities_stg
ALTER COLUMN lead_datetime DATE;


---------------------------------------------------------------
-- 6. Clean trade field
---------------------------------------------------------------
UPDATE opportunities_stg
SET trade = LOWER(LTRIM(RTRIM(trade)));

SELECT DISTINCT trade
FROM opportunities_stg;


---------------------------------------------------------------
-- 7. Clean stage field
---------------------------------------------------------------
UPDATE opportunities_stg
SET stage = LOWER(LTRIM(RTRIM(stage)));

SELECT DISTINCT stage
FROM opportunities_stg;


---------------------------------------------------------------
-- 8. Inspect schema again after modifications
---------------------------------------------------------------
EXEC sp_help 'opportunities_stg';


---------------------------------------------------------------
-- 9. Change expected_value to INT
---------------------------------------------------------------
ALTER TABLE opportunities_stg
ALTER COLUMN expected_value INT;


---------------------------------------------------------------
-- 10. Convert opportunity_created to DATE
---------------------------------------------------------------
ALTER TABLE opportunities_stg
ALTER COLUMN opportunity_created DATE;
