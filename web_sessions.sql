/* ============================================================
   Web Sessions Staging Cleanup Script
   - Inspect staging table
   - Standardize session_start
   - Clean and normalize user_email
   - Standardize UTM source, medium, campaign
   - Normalize landing_page fields
   ============================================================ */

---------------------------------------------------------------
-- 1. Inspect staging table
---------------------------------------------------------------
SELECT * 
FROM web_sessions_stg;


---------------------------------------------------------------
-- 2. Convert session_start to DATE
---------------------------------------------------------------
ALTER TABLE web_sessions_stg
ALTER COLUMN session_start DATE;


---------------------------------------------------------------
-- 3. Clean user_email field
---------------------------------------------------------------
-- Fix invalid emails by appending ".com" when:
--  - email does not match an email pattern
--  - contains spaces
--  - is NULL
--  - is too short


UPDATE web_sessions_stg
SET user_email = user_email + '.com' 
WHERE 
    user_email NOT LIKE '_%@_%._%'     
    OR user_email LIKE '% %'                           
    OR user_email IS NULL                   
    OR LEN(user_email) < 5;


---------------------------------------------------------------
-- 4. Inspect UTM source values
---------------------------------------------------------------
SELECT DISTINCT utm_source
FROM web_sessions_stg;


-----------------------------------------------------------
