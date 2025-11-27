/* ============================================================
   Ad Spend Daily Staging Cleanup Script
   - Create staging table
   - Standardize UTM source and medium
   - Inspect schema
   - Fix spend data type
   ============================================================ */

---------------------------------------------------------------
-- 1. Create ad spend staging table
---------------------------------------------------------------
SELECT *
INTO ad_spend_daily_stg
FROM ad_spend_daily;

-- Inspect staging table
SELECT * 
FROM ad_spend_daily_stg;


---------------------------------------------------------------
-- 2. Clean utm_source
---------------------------------------------------------------
SELECT DISTINCT utm_source
FROM ad_spend_daily_stg;

UPDATE ad_spend_daily_stg
SET utm_source = LOWER(LTRIM(RTRIM(utm_source)));


---------------------------------------------------------------
-- 3. Clean utm_medium
---------------------------------------------------------------
SELECT DISTINCT utm_medium
FROM ad_spend_daily_stg;

UPDATE ad_spend_daily_stg
SET utm_medium = LOWER(LTRIM(RTRIM(utm_medium)));


---------------------------------------------------------------
-- 4. Inspect table schema
---------------------------------------------------------------
EXEC sp_help 'ad_spend_daily_stg';


---------------------------------------------------------------
-- 5. Convert spend to DECIMAL
---------------------------------------------------------------
ALTER TABLE ad_spend_daily_stg
ALTER COLUMN spend DECIMAL(10,2);
