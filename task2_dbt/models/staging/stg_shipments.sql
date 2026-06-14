WITH source AS (

    SELECT * FROM {{ source('raw', 'shipments') }}

),

deduplicated AS (

    SELECT
        *,
        -- Keep the latest business state based on when the status changed, 
        -- using pipeline landing time as a tiebreaker[cite: 61].
        ROW_NUMBER() OVER (
            PARTITION BY shipment_id
            ORDER BY status_updated_at DESC, _ingested_at DESC
        ) AS row_num

    FROM source

),

final AS (

    SELECT
        -- Identifiers
        shipment_id,
        business_id,
        hub_id,

        -- Timestamps
        created_at,
        status_updated_at,
        _ingested_at,

        -- Dimensions
        status,
        governorate,
        is_fulfillment,

        -- Financials [cite: 60]
        CAST(cod_amount AS DECIMAL(18,2)) AS cod_amount,
        cod_collected,

        -- Derived boolean column: TRUE if cod_amount is greater than zero [cite: 62]
        CASE
            WHEN cod_amount IS NOT NULL AND cod_amount > 0 THEN TRUE
            ELSE FALSE
        END AS is_cod,

        -- Metrics
        attempt_count

    FROM deduplicated
    WHERE row_num = 1

)

SELECT * FROM final