
-- Test: Reconcile executive KPIs to fact tables
-- Zero returned rows means the test passes.

WITH opportunity_totals AS (

    SELECT
        COALESCE(SUM(
            CASE WHEN is_won = 1
                THEN amount_usd ELSE 0 END
        ), 0) AS expected_won_value,

        COALESCE(SUM(
            CASE WHEN is_open = 1
                THEN amount_usd ELSE 0 END
        ), 0) AS expected_pipeline_value

    FROM {{ ref('fct_opportunities') }}

),

payment_totals AS (

    SELECT
        COALESCE(SUM(payment_amount_usd), 0)
            AS expected_cash_collected
    FROM {{ ref('fct_payments') }}

),

actual AS (

    SELECT *
    FROM {{ ref('mart_revenue_summary') }}

)

SELECT
    a.won_deal_value,
    o.expected_won_value,
    a.open_pipeline_value,
    o.expected_pipeline_value,
    a.cash_collected,
    p.expected_cash_collected

FROM actual a
CROSS JOIN opportunity_totals o
CROSS JOIN payment_totals p

WHERE
    a.won_deal_value IS DISTINCT FROM
        o.expected_won_value

    OR a.open_pipeline_value IS DISTINCT FROM
        o.expected_pipeline_value

    OR a.cash_collected IS DISTINCT FROM
        p.expected_cash_collected
