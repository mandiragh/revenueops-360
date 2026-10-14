
-- Fact: Customer payments
-- Grain: One row per payment transaction

{{ config(materialized='table') }}

WITH payments AS (

    SELECT *
    FROM {{ ref('stg_payments') }}

)

SELECT
    payment_id,
    opportunity_id,
    payment_date,
    payment_amount_usd

FROM payments
