# E-Commerce Revenue & Customer Behavior Analytics (PostgreSQL)

## Executive Summary
This project delivers an end-to-end SQL data analytics pipeline built in **PostgreSQL** using the **Online Retail II** dataset (~500k raw transactional records). The analysis transforms raw, uncleaned order logs into an executive-ready business intelligence dataset to evaluate net revenue performance, return rates, customer retention metrics, and sales growth velocity.

---

## Technical Architecture & Workflow

The repository is structured into two sequential SQL execution phases:

1. `Cleaningdata.sql`: Raw data transformation, deduplication, type casting, string normalization, and return transaction flagging.
2. `online_retail_EDA.sql`: Execution of core business queries, customer lifetime value (CLV) calculations, and Month-over-Month (MoM) window functions.

---

## Data Cleaning & Staging Methodology

To ensure 100% analytical accuracy, the raw transactional data underwent several cleaning protocols:
* **Deduplication:** Identified and eliminated duplicate transaction rows across all attributes.
* **Transaction Classification:** Engineered a `transaction_type` conditional flag (`SALE` vs `RETURN`) based on invoice prefixes and negative quantity values to isolate gross sales from returned revenue.
* **String Normalization & Padding:** Cleaned `description` fields, removed leading/trailing whitespaces, and handled inconsistent string casing.
* **Inventory Filtering:** Filtered out system operational fee codes (e.g., `DOTCOM POSTAGE`, `MANUAL`, `AMAZON FEE`) from product-level analyses to reflect true physical inventory performance.

---

## Key Business Findings

* **Overall Revenue Performance:** Processed **$426,068.77 in Net Revenue** across **5,266 distinct orders**, identifying a **13.1% return rate** ($64,561.25 in returned items).
* **Product Drivers:** The top revenue-generating physical item across the entire platform was the **REGENCY CAKESTAND 3 TIER** ($13,768.63 revenue).
* **Customer Segmentation:** Registered customer accounts generate the overwhelming majority of revenue and unit volume compared to unregistered `Guest` checkouts. Top CLV accounts generated over $27,000+ in lifetime spending.
* **Time-Series Growth:** Utilized PostgreSQL window functions (`LAG()`) to track monthly performance shifts, accurately handling baseline comparisons via conditional logic.

---

## Core SQL Techniques Applied

* **Data Wrangling:** `DATE_TRUNC`, `CAST`, `COALESCE`, `NULLIF`, String Manipulation
* **Aggregation & Segmentation:** Conditional Aggregation (`CASE WHEN`), `GROUP BY`, `HAVING`
* **Advanced Analytics:** Window Functions (`LAG()`, `SUM() OVER()`), Common Table Expressions (CTEs)

---

## How to Run This Project

1. Import the raw `online_retail_transaction.zip` dataset into your PostgreSQL environment.
2. Execute `Cleaningdata.sql` to build the cleaned staging table `online_retail_EDA`.
3. Execute `online_retail_EDA.sql` to generate all business intelligence metrics and time-series summaries.
