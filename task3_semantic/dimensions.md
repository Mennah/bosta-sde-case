# How We Use Dimensions & Avoid Calculation Traps

To build accurate charts and avoid metrics returning weird or duplicate numbers, it helps to understand how our underlying tables are structured. The metrics in our repository live across two distinct layers.

### 1. Shipment-Level Metrics (The Flexible Layer)
The metrics `delivery_rate`, `cod_collection_rate`, `first_attempt_delivery_rate`, `avg_attempts_to_deliver`, and `fulfillment_delivery_rate` are calculated using individual package records.

* **Where they live:** Built directly on top of our `stg_shipments` table.
* **Slicing options:** You can slice and dice these metrics using any combination of `created_at`, `business_id`, `governorate`, `hub_id`, `status`, or `is_fulfillment`. Slicing across these fields is completely safe and won't cause unexpected data duplication.

### 2. Merchant-Day Metrics (The Strict Layer)
Our `rolling_7d_delivery_rate` is a unique metric because it relies on historical window calculations. It is pulled from our pre-aggregated `merchant_daily` table.

* **Slicing options:** This metric can **only** be sliced by `shipment_date` and `business_id`.
* **Important Constraints:**
  1. **Do not slice by Governorate or Hub:** Because merchants routinely ship packages to multiple cities and hubs on the same day, our 7-day rolling calculations are grouped strictly by merchant. Trying to break this metric down by geography or physical hub will return math errors or misleading totals.
  2. **Do not slice by Fulfillment Status:** This table groups standard shipping and fulfillment shipping together to view a merchant's business as a whole. If our operations teams need to track a rolling 7-day performance rate exclusively for fulfillment packages, we will need to adjust our base modeling to include `is_fulfillment` within the primary table keys.