## **Executive Summary**

Bosta is moving from old nightly data transfers to a modern, near-real-time streaming system for moving data from MongoDB to Redshift.

## **1\. The Problem**

The current system updates data only once every 24 hours by running heavy nightly scripts. This causes three issues:

* **Stale Data:** Reports are up to a day old.  
* **System Stress:** Nightly transfers slow down the live production database.  
* **Fragile Tech:** Maintaining two different types of scripts (full and partial updates) is messy and breaks easily.

## **2\. The Solution**

We are adopting **CDC (Change Data Capture)** using **Debezium and Kafka**.

* **How it works:** Instead of copying whole tables at night, the new system automatically copies individual data changes within seconds of them happening.  
* **Why this tool?**   
  Alternatives like AWS DMS and Estuary Flow were rejected because Kafka is more mature, flexible, and handles sudden data changes better.

AWS DMS (Database Migration Service)

-  weak schema evolution handling (it depends on how frequent the schema evolution happens,  I still see this is a valid option if this point is not frequent)  
- AWS vendor lock-in risk.   
   

Estuary Flow 

- A modern managed CDC platform that bundles source capture, buffering, and destination loading into one service. Promising for smaller teams, but relatively immature for large-scale production deployments, and introduces vendor dependency.

## **3\. Benefits & Trade-offs**

### **The Good**

* **Fresh Data:** Redshift updates in seconds, not hours.  
* **Safe for Production:** Debezium reads exclusively from MongoDB's oplog — never querying collections directly. It reads from a backup database copy (`Secondary Replica`), meaning zero slowdowns for live users.  
* **Flexible:** If fields change or get added to the database, the system adapts without breaking.

### **The Risks & Fixes**

* **Complexity:** Managing Kafka is harder.   
  *Fix: Use a managed service (like AWS MSK).*  
* **Missed Data Risk:** If the system goes offline for too long, it might miss changes.   
  *Fix: Keep a 72-hour history log and set up alerts for delays.*  
* **Slight Delay:** Data takes a few seconds/minutes to arrive.   
  *Accepted: Fine for analytics, just not for instant transactions.*

## **4\. Monitoring & Alerts**

The pipeline will be monitored 24/7. Critical alerts will be sent to the team based on severity:

| Severity | Issue | Action Required |
| :---- | :---- | :---- |
| **P1** | Pipeline completely dead | Fix within 15 minutes |
| **P2** | The system is lagging/slow | Fix within 30 minutes |
| **P3** | Minor data quality warning | Review within 2 hours |

