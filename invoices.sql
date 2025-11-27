/* ============================================================
   Invoice Staging Cleanup & Revenue Analysis
   - Create invoice staging table
   - Inspect and clean invoice data
   - Fix data types for amount and invoice_datetime
   - Clean malformed emails
   - Explore revenue by UTM medium (via leads_stg)
   ============================================================ */

---------------------------------------------------------------
-- 1. Create invoice staging table
---------------------------------------------------------------
SELECT *
INTO invoice_stg
FROM invoices;

-- Inspect staging data
SELECT *
FROM invoice_stg;

-- Quick check: total revenue
SELECT SUM(amount) 
FROM invoice_stg;


---------------------------------------------------------------
-- 2. Check for duplicate invoices
---------------------------------------------------------------
SELECT * 
FROM invoice_stg
WHERE invoice_id IN (
    SELECT invoice_id
    FROM invoice_stg
    GROUP BY invoice_id
    HAVING COUNT(*) > 1
);


---------------------------------------------------------------
-- 3. Inspect schema
---------------------------------------------------------------
EXEC sp_help 'invoice_stg';


---------------------------------------------------------------
-- 4. Fix data types for amount and invoice_datetime
---------------------------------------------------------------
ALTER TABLE invoice_stg
ALTER COLUMN amount DECIMAL(10,2);

ALTER TABLE invoice_stg
ALTER COLUMN invoice_datetime DATE;


---------------------------------------------------------------
-- 5. Check for bad emails
---------------------------------------------------------------
SELECT user_email
FROM invoice_stg
WHERE user_email NOT LIKE '_%@_%._%'     
   OR user_email LIKE '% %'                           
   OR user_email IS NULL                   
   OR LEN(user_email) < 5; 


-- Preview email fixes
SELECT DISTINCT
    user_email,
    user_email + '.com' AS fixed_email
FROM invoice_stg
WHERE 
    user_email NOT LIKE '_%@_%._%'     
    OR user_email LIKE '% %'                           
    OR user_email IS NULL                   
    OR LEN(user_email) < 5;


-- Apply email fix (append ".com" for invalid/NULL/short emails)
UPDATE invoice_stg
SET user_email = user_email + '.com' 
WHERE 
    user_email NOT LIKE '_%@_%._%'     
    OR user_email LIKE '% %'                           
    OR user_email IS NULL                   
    OR LEN(user_email) < 5;


-- Re-check fixed emails
SELECT 
    CASE 
        WHEN user_email NOT LIKE '_%@_%._%'     
             OR user_email LIKE '% %'                           
             OR user_email IS NULL                   
             OR LEN(user_email) < 5
        THEN user_email + '.com'
        ELSE user_email
    END AS fixed_email
FROM invoice_stg;


---------------------------------------------------------------
-- 6. Revenue per medium (via leads_stg)
-- NOTE:
-- This analysis showed revenue by channel summed to MORE than
-- total revenue because the same user_email can appear multiple
-- times in leads_stg with different utm_medium values.
-- Example: alexatgmaildotcom is assigned both 'cpc' and 'display',
-- causing double-counting when joined naively.
---------------------------------------------------------------
WITH ld AS (
    SELECT user_email, utm_medium
    FROM leads_stg
),
inv AS (
    SELECT user_email, amount
    FROM invoice_stg
)
SELECT 
    ld.utm_medium AS utm_medium, 
    SUM(inv.amount) AS revenue
FROM inv
LEFT JOIN ld 
    ON inv.user_email = ld.user_email
GROUP BY ld.utm_medium;
