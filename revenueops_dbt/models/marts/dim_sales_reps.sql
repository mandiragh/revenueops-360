
-- Dimension: Sales representatives
-- Grain: One row per sales representative name

{{ config(materialized='table') }}

WITH sales_reps AS (

    SELECT DISTINCT
        TRIM(sales_rep) AS sales_rep
    FROM {{ ref('stg_opportunities') }}
    WHERE sales_rep IS NOT NULL
      AND TRIM(sales_rep) <> ''

)

SELECT
    MD5(UPPER(sales_rep)) AS sales_rep_id,
    sales_rep

FROM sales_reps
