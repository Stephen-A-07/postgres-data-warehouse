# PostgreSQL Data Warehouse

A modern **PostgreSQL Data Warehouse** built using the **Medallion Architecture (Bronze → Silver → Gold)**. This project integrates CRM and ERP datasets, applies data cleansing and transformation, and delivers a business-ready **star schema** optimized for analytical reporting and Business Intelligence (BI).

---

# Project Overview

This project demonstrates an end-to-end data warehousing workflow using PostgreSQL.

The pipeline consists of three layers:

* **Bronze Layer** – Ingests raw CSV files without modifications.
* **Silver Layer** – Cleans, standardizes, validates, and transforms the raw data.
* **Gold Layer** – Creates a dimensional model (star schema) consisting of fact and dimension views for analytics.

The project follows industry-standard ETL and data warehousing practices and is designed as a portfolio project for Data Engineering and Data Analytics roles.

---

# Architecture

```
                     Source Systems
      ┌───────────────────────────────────────┐
      │                                       │
      │ CRM                                  ERP
      │ • cust_info.csv                      • CUST_AZ12.csv
      │ • prd_info.csv                       • LOC_A101.csv
      │ • sales_details.csv                  • PX_CAT_G1V2.csv
      └───────────────────────────────────────┘
                         │
                         ▼
                  Bronze Layer
          Raw data loaded without changes
                         │
                         ▼
                  Silver Layer
      Data cleaning, validation, standardization,
      deduplication, and business transformations
                         │
                         ▼
                   Gold Layer
             Business-ready Star Schema
                         │
                         ▼
                 Dashboards / Analytics
```

---

# Gold Layer Star Schema

```
          gold.dim_customers
                   │
                   │
                   ▼
             gold.fact_sales
                   ▲
                   │
                   │
          gold.dim_products
```

---

# Features

* Medallion Architecture implementation
* PostgreSQL-based ETL pipeline
* Raw data ingestion using `COPY`
* Data cleansing and validation
* Business rule transformations
* Star schema dimensional modeling
* Customer and Product dimensions
* Sales fact table
* SQL-based data quality checks
* Modular and organized project structure

---

# Repository Structure

```
postgres-data-warehouse/
│
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   │
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── scripts/
│   ├── init_database.sql
│   │
│   ├── bronze/
│   │   ├── create_tables.sql
│   │   └── load_data.sql
│   │
│   ├── silver/
│   │   ├── create_table.sql
│   │   └── load_clean_data.sql
│   │
│   ├── gold/
│   │   └── ddl_gold.sql
│   │
│   ├── tests/
│   │   ├── quality_check_silver_layer.sql
│   │   └── quality_checks_gold.sql
│   │
│   └── data_catalog.md
│
└── README.md
```

---

# Data Sources

| Source System | Dataset             | Description                      |
| ------------- | ------------------- | -------------------------------- |
| CRM           | `cust_info.csv`     | Customer master information      |
| CRM           | `prd_info.csv`      | Product information              |
| CRM           | `sales_details.csv` | Sales transactions               |
| ERP           | `CUST_AZ12.csv`     | Customer demographic information |
| ERP           | `LOC_A101.csv`      | Customer location information    |
| ERP           | `PX_CAT_G1V2.csv`   | Product category mapping         |

---

# ETL Workflow

## Bronze Layer

Purpose:

* Load source CSV files into PostgreSQL
* Preserve original data
* No transformations

Tasks:

* Create Bronze tables
* Import CSV files using `COPY`
* Maintain raw source data

---

## Silver Layer

Purpose:

Prepare clean and reliable datasets for downstream analytics.

Transformations include:

* Removing duplicates
* Standardizing data formats
* Handling missing values
* Correcting invalid records
* Data type conversions
* Applying business rules
* Improving data consistency

---

## Gold Layer

Purpose:

Provide a business-friendly dimensional model for reporting.

Objects:

| Object               | Type | Description                                                  |
| -------------------- | ---- | ------------------------------------------------------------ |
| `gold.dim_customers` | View | Customer dimension enriched with demographics and location   |
| `gold.dim_products`  | View | Product dimension with category information                  |
| `gold.fact_sales`    | View | Sales fact table referencing customer and product dimensions |

---

# Getting Started

## Prerequisites

* PostgreSQL 14 or later
* pgAdmin or psql
* Source CSV files

---

## Step 1 — Create Database

Run:

```sql
\i scripts/init_database.sql
```

This script:

* Creates the DataWarehouse database
* Creates the Bronze schema
* Creates the Silver schema
* Creates the Gold schema

---

## Step 2 — Load Bronze Layer

```sql
\i scripts/bronze/create_tables.sql
\i scripts/bronze/load_data.sql
```

> **Note:** Update the file paths inside `load_data.sql` to point to the location of your CSV files before executing the script.

---

## Step 3 — Load Silver Layer

```sql
\i scripts/silver/create_table.sql
\i scripts/silver/load_clean_data.sql
```

---

## Step 4 — Create Gold Views

```sql
\i scripts/gold/ddl_gold.sql
```

---

## Step 5 — Run Data Quality Checks

```sql
\i scripts/tests/quality_check_silver_layer.sql
\i scripts/tests/quality_checks_gold.sql
```

---

# Data Quality Validation

The project includes SQL validation scripts to verify data quality.

Checks include:

* Duplicate primary keys
* Null value validation
* Referential integrity
* Dimension-to-fact relationships
* Active product validation
* Star schema consistency

---

# Data Catalog

Column-level documentation for all Gold layer objects is available in:

```
scripts/data_catalog.md
```

---

# Technologies Used

* PostgreSQL
* SQL
* ETL
* Data Warehousing
* Medallion Architecture
* Star Schema
* Git
* GitHub

---

# Skills Demonstrated

* Data Warehousing
* SQL Development
* ETL Pipeline Design
* Data Cleaning
* Data Modeling
* Dimensional Modeling
* Database Design
* Data Validation
* Query Optimization
* Analytical SQL

---

# Future Improvements

* Incremental loading
* Slowly Changing Dimensions (SCD Type 2)
* Automated ETL scheduling
* Index optimization
* Materialized views
* Performance benchmarking
* Dashboard integration using Power BI or Tableau

---

# License

This project is licensed under the MIT License.
