## **1\. How Data Flows**

The pipeline is split into two independent sections:

     MongoDB (Production App)  
                 │  
  \[STREAMING LAYER \- Runs 24/7 Alone\]  
                 │  
      Debezium (Reads data changes)  
                 │  
      Kafka (Buffers data for 7 days)  
                 │  
      Redshift Raw Layer (Data is only added, never deleted)  
                 │  
  \[ORCHESTRATION LAYER \- Managed by Airflow\]  
                 │  
      Redshift Staging Layer (Data is cleaned & deduplicated)  
                 │  
      Redshift Mart Layer (Data is summarized for reports)  
                 │  
      Dashboards / Apps

**The Golden Rules:** 

- The streaming layer runs completely on its own. Airflow only steps in *after* the data lands safely in Redshift's Raw Layer. Because data is never deleted from the Raw Layer, fixes and re-runs are always safe.  
- The raw layer in Redshift is \*\*append-only and never deleted. Backfills load into it freely. dbt deduplication (keeping latest by \`\_ingested\_at\`) handles any resulting duplicates automatically during transformation.

## **2\. The 3 Airflow Workflows (DAGs)**

### **DAG 1: dag\_cdc\_health\_check (Every 15 mins)**

**Purpose:** Monitors the system to ensure no data is stuck or delayed.

Check if system is running  
            ↓  
Check for data delays (lag)  
            ↓  
Check if Redshift is receiving new data  
            ↓  
Alert team if anything is broken

### **DAG 2: dag\_dbt\_transform (Every 30 mins)**

**Purpose:** Cleans the raw data and prepares it for business dashboards.

Check for new raw data  
            ↓  
Clean and deduplicate data  
            ↓  
Build business summary metrics  
            ↓  
Run data quality tests  
            ↓  
Block bad data / Alert team if tests fail

### **DAG 3: dag\_backfill (Manual Trigger Only)**

**Purpose:** Safely reloads or fixes historical data when needed.

Validate what needs fixing  
            ↓  
Pause live data stream for those specific tables  
            ↓  
Load historical data into Raw Layer  
            ↓  
Resume live data stream  
            ↓  
Re-run cleaning and tests on all affected data  
            ↓  
Notify the team when finished

