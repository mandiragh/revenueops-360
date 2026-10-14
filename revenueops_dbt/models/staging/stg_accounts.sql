
-- Model: stg_accounts
-- Purpose: Standardize raw customer account data

WITH source_data AS (

    SELECT *
    FROM {{ source('raw_sales', 'accounts') }}

),

cleaned_accounts AS (

    SELECT
        TRIM(ACCOUNT_ID) AS account_id,
        TRIM(ACCOUNT_NAME) AS account_name,
        TRIM(INDUSTRY) AS industry,
        TRIM(REGION) AS region,
        CREATED_DATE AS created_date

    FROM source_data

)

SELECT *
FROM cleaned_accounts
