
-- Model: stg_payments
-- Purpose: Clean and standardize payment records

WITH source_data AS (

    SELECT *
    FROM {{ source('raw_sales', 'payments') }}

),

cleaned_payments AS (

    SELECT
        TRIM(PAYMENT_ID) AS payment_id,
        TRIM(OPPORTUNITY_ID) AS opportunity_id,
        PAYMENT_DATE AS payment_date,
        CAST(PAYMENT_AMOUNT_USD AS NUMBER(12,2))
            AS payment_amount_usd

    FROM source_data

)

SELECT *
FROM cleaned_payments
