
## Future Created Dates
Failure Mode: System clock misconfigurations or timezone sync errors flag a shipment's `created_at` timestamp with a time ahead of the current reality.
Downstream Business Impact: Directly skews daily volume reporting.
Alert & Remediation Plan: This test triggers a dbt Cloud failure alert sent straight to the #data-ops Slack channel.

Automated Detection Test
  SELECT *
  FROM {{ ref('stg_shipments') }}
  WHERE created_at > CURRENT_TIMESTAMP


## COD Collected > COD Amount
Failure Mode: An order is flagged as collected (cod_collected = TRUE), but its cod_amount is registered as 0 or negative.
Downstream Business Impact: Corrupts financial auditing and reporting, causing major gaps during daily cash reconciliation and executive balance checks.
Alert & Remediation Plan: If this test fails during a run, dbt Cloud fires a notification to #data-ops and #finance-alerts on Slack.

SELECT *
FROM {{ ref('stg_shipments') }}
WHERE cod_collected = TRUE
  AND cod_amount <= 0


## Delivered Before Created
Failure Mode: A status update record enters the warehouse with a status_updated_at milestone timestamp that happens before the actual order's created_at timestamp.
Downstream Business Impact: Completely breaks the integrity of lifecycle tracking. It creates impossible timeline durations (negative delivery times).
Alert & Remediation Plan: This test runs inline during the core transformation workflow. A failure triggers a warning alert in the #data-ops Slack channel. 

SELECT *
FROM {{ ref('stg_shipments') }}
WHERE status_updated_at < created_at
