
-- Dimension: Customers
-- Grain: One row per account

{{ config(materialized='table') }}

WITH accounts AS (

    SELECT *
    FROM {{ ref('stg_accounts') }}

)

SELECT
    account_id,
    account_name,
    industry,
    region,
    created_date

FROM accounts
