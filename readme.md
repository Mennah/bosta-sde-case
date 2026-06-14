**Bosta Senior Data Engineer Case Study Introduction** 

This repository contains my solution for the Bosta Senior Data Engineer case study. The submission covers three areas: 

•    
CDC architecture and orchestration 

•    
dbt modelling and data quality 

•    
Semantic layer design and governance 

**My Approach** 

•    
CDC captures operational changes reliably. 

•    
dbt transforms and validates the data. 

•    
The semantic layer owns business definitions. 

•    
Downstream consumers reuse those definitions rather than recreating them. 

I also tried to favor solutions that would still work when data volumes grow significantly beyond today's scale. 

**Task 1 – CDC Architecture** 

For the MongoDB → Redshift pipeline, I proposed an event-driven CDC architecture based on MongoDB Change Streams, Debezium, Kafka, and Redshift. 

The primary goals were: 

•    
Minimize load on production systems •    
Reduce warehouse latency 

•    
Support schema evolution 

•    
Allow safe replay and recovery 

The detailed reasoning and trade-offs are documented in: 

task1\_pipeline/ADR.md 

The orchestration design, failure handling strategy, and backfill approach are documented in: task1\_pipeline/Orchestration Sketch.md 

1  
**Task 2 – dbt Modelling & Data Quality Staging Layer** 

The staging model standardizes the raw shipment data by: 

•    
Casting source fields to consistent types 

•    
Applying a naming convention 

•    
Deduplicating shipments using the latest ingestion timestamp •    
Deriving useful business flags such as is\_cod 

**Merchant Daily Mart** 

The mart aggregates shipment activity at a merchant-day grain and provides operational KPIs such as: 

•    
Shipment counts 

•  •    
Delivery performance 

COD collection performance •    
Attempt metrics 

•    
Rolling delivery rates 

**Data Quality** 

I included both generic and custom tests and documented three realistic failure scenarios that could silently impact reporting. 

The analysis can be found in: 

task2\_dbt/dq\_analysis.md 

**Task 3 – Semantic Layer** 

The semantic layer introduces a single definition for commonly used business metrics such as: 

•  •    
Delivery Rate 

COD Collection Rate 

•    
First Attempt Delivery Rate •    
Average Attempts to Deliver 

•    
Fulfillment Delivery Rate 

The objective is to ensure that BI dashboards, analysts, and future AI applications all calculate metrics consistently. 

Metric definitions are located in: 

task3\_semantic/metrics.yaml 

2  
Additional documentation: 

task3\_semantic/dimensions.md 

task3\_semantic/governance.md 

**Trade-offs** 

A few conscious trade-offs were made: 

**Kafka Adds Operational Complexity** 

Using Kafka and Debezium introduces more infrastructure than a simple batch ingestion process. 

I accepted that trade-off because it provides replayability, scalability, and near real-time ingestion, which are important for a platform of Bosta's size. 

**Eventual Consistency** 

The proposed architecture is not strictly real-time. 

There will always be a small delay between operational activity and analytical availability, but that delay is acceptable for reporting workloads and simplifies system reliability. 

**Additional Storage Usage** 

Retaining CDC history increases storage costs. 

**What I Would Do With More Time** 

If this were part of a full sprint rather than a case study, I would likely add: 

•    
More extensive dbt-expectations tests •    
End-to-end integration testing •    
CI/CD validation for dbt and semantic layer changes 

**Running the dbt Models** 

Run all models: 

dbt run 

Run tests: 

3  
dbt test 

Build models and execute tests together: 

dbt build 

Generate documentation: 

dbt docs generate 

dbt docs serve 

**Closing Notes** 

The goal of this submission was not to produce the most complex solution possible, but rather to demonstrate how I would think about building and operating a reliable data platform in a production environment. 

Where appropriate, I prioritized clarity, maintainability, and operational safety over unnecessary complexity. 

4