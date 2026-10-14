
-- Model: mart_revenue_summary
-- Grain: One row for the entire business

{{ config(materialized='table') }}

WITH opportunity_metrics AS (

    SELECT
        COUNT(*) AS total_opportunities,

        COUNT_IF(is_won = 1) AS won_deals,

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

    FROM {{ ref('fct_opportunities') }}

),

payment_metrics AS (

    SELECT
        COALESCE(
            SUM(payment_amount_usd), 0
        ) AS cash_collected

    FROM {{ ref('fct_payments') }}

)

SELECT
    o.total_opportunities,
    o.won_deals,
    o.won_deal_value,
    o.open_pipeline_value,
    p.cash_collected

FROM opportunity_metrics o
CROSS JOIN payment_metrics p
