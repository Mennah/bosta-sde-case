/* Future Created Dates*/
  SELECT *
  FROM {{ ref('stg_shipments') }}
  WHERE created_at > CURRENT_TIMESTAMP

/*COD Collected > COD Amount*/
SELECT *
FROM {{ ref('stg_shipments') }}
WHERE cod_collected = TRUE
  AND cod_amount <= 0

/*Delivered Before Created*/
SELECT *
FROM {{ ref('stg_shipments') }}
WHERE status_updated_at < created_at