/* ============================================================
   Leads Staging Cleanup Script
   - Create staging copy
   - Check duplicates
   - Clean session_id
   - Normalize user_email
   - Standardize datetime, trade, status
   - Validate zip and state
   - Fill UTM fields from web_sessions_stg
   - Standardize UTM fields and handle NULLs
   ============================================================ */

---------------------------------------------------------------
-- 1. Create leads staging table
---------------------------------------------------------------
SELECT *
INTO leads_stg
FROM leads;

SELECT * 
FROM leads_stg;

-- Count distinct emails
SELECT COUNT(DISTINCT user_email) 
FROM leads_stg;


---------------------------------------------------------------
-- 2. Check duplicate lead_id
---------------------------------------------------------------
SELECT *
FROM leads_stg
WHERE lead_id IN (
    SELECT lead_id
    FROM leads_stg
    GROUP BY lead_id
    HAVING COUNT(*) > 1
);


---------------------------------------------------------------
-- 3. Clean session_id (fix NULLs)
---------------------------------------------------------------
ALTER TABLE leads_stg
ALTER COLUMN session_id VARCHAR(50);

UPDATE leads_stg
SET session_id = 'unknown'
WHERE session_id IS NULL;

EXEC sp_help 'leads_stg';


---------------------------------------------------------------
-- 4. Clean user_email field
---------------------------------------------------------------
-- Preview fixes
SELECT DISTINCT
    user_email,
    user_email + '.com' AS fixed_email
FROM leads_stg
WHERE 
    user_email NOT LIKE '_%@_%._%'     
    OR user_email LIKE '% %'                           
    OR user_email IS NULL                   
    OR LEN(user_email) < 5;

-- Apply email fix
UPDATE leads_stg
SET user_email = user_email + '.com' 
WHERE 
    user_email NOT LIKE '_%@_%._%'     
    OR user_email LIKE '% %'                           
    OR user_email IS NULL                   
    OR LEN(user_email) < 5;


---------------------------------------------------------------
-- 5. Convert lead_datetime to DATE
---------------------------------------------------------------
ALTER TABLE leads_stg
ALTER COLUMN lead_datetime DATE;


---------------------------------------------------------------
-- 6. Clean trade field
---------------------------------------------------------------
UPDATE leads_stg
SET trade = LOWER(LTRIM(RTRIM(trade)));

SELECT DISTINCT trade
FROM leads_stg;

-- Fix known variant
UPDATE leads_stg
SET trade = 'roofing_crm'
WHERE trade = 'roofingcrm';


---------------------------------------------------------------
-- 7. Validate zip and state formats
---------------------------------------------------------------
SELECT zip
FROM leads_stg
WHERE LEN(zip) <> 5;

SELECT [state]
FROM leads_stg
WHERE LEN([state]) <> 3;


---------------------------------------------------------------
-- 8. Clean status field
---------------------------------------------------------------
UPDATE leads_stg
SET [status] = LOWER(LTRIM(RTRIM([status])));

SELECT DISTINCT [status]
FROM leads_stg;

SELECT * 
FROM leads_stg;


---------------------------------------------------------------
-- 9. Fill NULL utm_source from web sessions
---------------------------------------------------------------
SELECT 
    l.utm_source AS leads_utm,
    l.session_id,
    w.session_id,
    w.utm_source AS websessions_utm
FROM leads_stg l
INNER JOIN web_sessions_stg w
    ON l.session_id = w.session_id
WHERE l.utm_source IS NULL
  AND w.utm_source IS NOT NULL;

-- Apply fill logic
UPDATE l
SET l.utm_source = w.utm_source
FROM leads_stg l
INNER JOIN web_sessions_stg w
    ON l.session_id = w.session_id
WHERE l.utm_source IS NULL
  AND w.utm_source IS NOT NULL;

SELECT DISTINCT utm_source
FROM leads_stg;

-- Clean remaining NULLs
UPDATE leads_stg
SET utm_source = 'unknown'
WHERE utm_source IS NULL;


---------------------------------------------------------------
-- 10. Clean utm_medium field
---------------------------------------------------------------
UPDATE leads_stg
SET utm_medium = LOWER(LTRIM(RTRIM(utm_medium)));

SELECT DISTINCT utm_medium
FROM leads_stg;

SELECT * FROM leads_stg;

-- Fix special cases
UPDATE leads_stg
SET utm_medium = 'none'
WHERE utm_medium = '(none)';

-- Fill NULLs from web sessions
UPDATE l
SET l.utm_medium = w.utm_medium
FROM leads_stg l
INNER JOIN web_sessions_stg w
    ON l.session_id = w.session_id
WHERE l.utm_medium IS NULL
  AND w.utm_medium IS NOT NULL;

-- Clean remaining NULLs
UPDATE leads_stg
SET utm_medium = 'unknown'
WHERE utm_medium IS NULL;


---------------------------------------------------------------
-- 11. Clean utm_campaign field
---------------------------------------------------------------
UPDATE leads_stg
SET utm_campaign = LOWER(LTRIM(RTRIM(utm_campaign)));

SELECT DISTINCT utm_campaign
FROM leads_stg
ORDER BY utm_campaign ASC;

-- Fill NULLs from web sessions
UPDATE l
SET l.utm_campaign = w.utm_campaign
FROM leads_stg l
INNER JOIN web_sessions_stg w
    ON l.session_id = w.session_id
WHERE l.utm_campaign IS NULL
  AND w.utm_campaign IS NOT NULL;

-- Clean remaining NULLs
UPDATE leads_stg
SET utm_campaign = 'unknown'
WHERE utm_campaign IS NULL;


---------------------------------------------------------------
-- 12. Final review
---------------------------------------------------------------
SELECT * 
FROM leads_stg;


