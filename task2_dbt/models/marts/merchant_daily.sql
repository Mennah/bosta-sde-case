WITH shipments AS (

    SELECT * FROM {{ ref('stg_shipments') }}

),

daily_aggregates AS (

    SELECT
        business_id,
        DATE(created_at) AS shipment_date,

       
        COUNT(shipment_id) AS total_shipments,
        COUNT(CASE WHEN status = 'DELIVERED' THEN 1 END) AS delivered_count,
        COUNT(CASE WHEN status = 'DELIVERED' AND attempt_count = 1 THEN 1 END) AS delivered_first_attempt_count,
        COUNT(CASE WHEN status = 'RETURNED' THEN 1 END) AS returned_count,
        COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) AS cancelled_count,

        -- Delivery rate denominator (excludes ongoing states) 
        COUNT(CASE WHEN status IN ('DELIVERED','RETURNED','CANCELLED') THEN 1 END) AS concluded_count,

        -- COD metrics 
        SUM(CASE WHEN cod_collected = TRUE THEN cod_amount ELSE 0 END) AS cod_collected_amount,
        COUNT(CASE WHEN is_cod = TRUE THEN 1 END) AS cod_eligible_count,
        COUNT(CASE WHEN is_cod = TRUE AND cod_collected = TRUE THEN 1 END) AS cod_collected_count,

    FROM shipments
    GROUP BY
        business_id,
        DATE(created_at)

),

with_rates AS (

    SELECT
        *,
        -- Delivery Rate = Delivered / (Delivered + Returned + Cancelled) 
        CASE
            WHEN concluded_count = 0 THEN NULL
            ELSE ROUND(delivered_count * 1.0 / concluded_count, 4)
        END AS delivery_rate,

        -- COD Collection Rate = Collected Count / Eligible Count 
        CASE
            WHEN cod_eligible_count = 0 THEN NULL
            ELSE ROUND(cod_collected_count * 1.0 / cod_eligible_count, 4)
        END AS cod_collection_rate

    FROM daily_aggregates

),

with_rolling AS (

    SELECT
        *,
        -- 7-day rolling delivery rate (volume-weighted)
        ROUND(
            SUM(delivered_count) OVER (
                PARTITION BY business_id
                ORDER BY shipment_date
                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            ) * 1.0 /
            NULLIF(
                SUM(concluded_count) OVER (
                    PARTITION BY business_id
                    ORDER BY shipment_date
                    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
                ),
            0),
        4) AS rolling_7d_delivery_rate

    FROM with_rates

)

SELECT 
    business_id,
    shipment_date,
    total_shipments,
    delivered_count,
    delivered_first_attempt_count,
    returned_count,
    cancelled_count,
    cod_collected_amount,
    cod_eligible_count,
    cod_collected_count,
    avg_attempt_count,
    delivered_attempt_count_sum,
    delivery_rate,
    cod_collection_rate,
    rolling_7d_delivery_rate
FROM with_rolling
