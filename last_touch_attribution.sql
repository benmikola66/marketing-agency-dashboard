
/* ============================================================
   Last-Touch Attribution Query (Web Sessions → Invoices)
   - Join web sessions to invoices at the user_email level
   - Attribute revenue to the last touch (most recent session
     on or before the invoice_datetime)
   - Aggregate revenue credit by source/medium/campaign

   NOTE:
   The UTM source and medium fields in this dataset are intentionally messy
   (e.g., medium = 'cpc', source = 'newsletter'). This is fake data and does
   not reflect a realistic taxonomy, but is used as-is.
   ============================================================ */

---------------------------------------------------------------
-- 1. Rank touches per user + invoice (last touch = rn = 1)
---------------------------------------------------------------
WITH ranked_touches AS (
    SELECT
        ws.user_email,
        ws.utm_source,
        ws.utm_medium,
        ws.utm_campaign,
        ws.session_start,
        i.invoice_datetime,
        i.amount,
        ROW_NUMBER() OVER (
            PARTITION BY ws.user_email, i.invoice_datetime
            ORDER BY ws.session_start DESC
        ) AS rn
    FROM web_sessions_stg ws
    JOIN invoice_stg i
      ON ws.user_email = i.user_email
     AND ws.session_start <= i.invoice_datetime
)
---------------------------------------------------------------
-- 2. Take only the last touch and aggregate revenue credit
---------------------------------------------------------------
SELECT
    user_email,
    utm_source,
    utm_medium,
    utm_campaign,
    SUM(amount) AS revenue_credit
FROM ranked_touches
WHERE rn = 1
GROUP BY
    user_email, utm_source, utm_medium, utm_campaign;

