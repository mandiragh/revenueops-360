
-- Model: mart_sales_performance
-- Grain: One row per sales representative

{{ config(materialized='table') }}

WITH opportunities AS (

    SELECT *
    FROM {{ ref('fct_opportunities') }}

),

sales_reps AS (

    SELECT *
    FROM {{ ref('dim_sales_reps') }}

),

aggregated AS (

    SELECT
        sales_rep_id,

        COUNT(*) AS total_opportunities,

        COUNT_IF(is_won = 1) AS won_deals,

        COUNT_IF(stage = 'Closed Lost') AS lost_deals,

        SUM(
            CASE
                WHEN is_won = 1 THEN amount_usd
                ELSE 0
            END
        ) AS won_deal_value,

        SUM(
            CASE
                WHEN is_open = 1 THEN amount_usd
                ELSE 0
            END
        ) AS open_pipeline_value

    FROM opportunities
    GROUP BY sales_rep_id

)

SELECT
    r.sales_rep_id,
    r.sales_rep,

    COALESCE(a.total_opportunities, 0)
        AS total_opportunities,

    COALESCE(a.won_deals, 0) AS won_deals,
    COALESCE(a.lost_deals, 0) AS lost_deals,

    COALESCE(a.won_deal_value, 0)
        AS won_deal_value,

    COALESCE(a.open_pipeline_value, 0)
        AS open_pipeline_value,

    ROUND(
        100.0 * a.won_deals /
        NULLIF(a.won_deals + a.lost_deals, 0),
        2
    ) AS win_rate_percent

FROM sales_reps r
LEFT JOIN aggregated a
    ON r.sales_rep_id = a.sales_rep_id


