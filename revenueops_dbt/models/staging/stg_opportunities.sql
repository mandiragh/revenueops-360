
-- Model: stg_opportunities
-- Purpose: Standardize raw sales opportunity data

WITH source_data AS (

    SELECT *
    FROM {{ source('raw_sales', 'opportunities') }}

),

cleaned_opportunities AS (

    SELECT
        TRIM(OPPORTUNITY_ID) AS opportunity_id,
        TRIM(ACCOUNT_ID) AS account_id,
        TRIM(SALES_REP) AS sales_rep,

        CREATED_DATE AS created_date,
        EXPECTED_CLOSE_DATE AS expected_close_date,

        TRIM(STAGE) AS stage,

        CAST(AMOUNT_USD AS NUMBER(12,2)) AS amount_usd

    FROM source_data

)

SELECT *
FROM cleaned_opportunities
