
-- This test fails unless the mart contains exactly one row.

SELECT COUNT(*) AS actual_rows
FROM {{ ref('mart_revenue_summary') }}
HAVING COUNT(*) <> 1
