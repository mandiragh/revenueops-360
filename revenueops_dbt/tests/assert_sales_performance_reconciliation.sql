
-- Compare salesperson totals to company-wide totals.

WITH sales_totals AS (

    SELECT
        COALESCE(SUM(won_deal_value), 0)
            AS won_deal_value,
        COALESCE(SUM(open_pipeline_value), 0)
            AS open_pipeline_value
    FROM {{ ref('mart_sales_performance') }}

),

revenue_totals AS (

    SELECT
        won_deal_value,
        open_pipeline_value
    FROM {{ ref('mart_revenue_summary') }}

)

SELECT *
FROM sales_totals s
CROSS JOIN revenue_totals r

WHERE
    s.won_deal_value IS DISTINCT FROM
        r.won_deal_value
    OR
    s.open_pipeline_value IS DISTINCT FROM
        r.open_pipeline_value
