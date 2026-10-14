
-- Fact: Sales opportunities
-- Grain: One row per opportunity

{{ config(materialized='table') }}

WITH opportunities AS (

    SELECT *
    FROM {{ ref('stg_opportunities') }}

)

SELECT
    opportunity_id,
    account_id,

    MD5(UPPER(TRIM(sales_rep))) AS sales_rep_id,

    created_date,
    expected_close_date,
    stage,
    amount_usd,

    CASE
        WHEN stage = 'Closed Won' THEN 1
        ELSE 0
    END AS is_won,

    CASE
        WHEN stage NOT IN ('Closed Won', 'Closed Lost')
        THEN 1
        ELSE 0
    END AS is_open

FROM opportunities
