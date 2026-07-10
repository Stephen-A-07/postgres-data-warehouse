-- ============================================================================
-- Bronze Layer Tables
-- ============================================================================
-- Purpose:
-- Create all tables in the Bronze layer of the Data Warehouse.
--
-- The Bronze layer stores raw data ingested from source systems with minimal
-- or no transformations. These tables serve as the landing zone for ETL/ELT
-- pipelines.
--
-- Source Systems:
--   • CRM (Customer Relationship Management)
--   • ERP (Enterprise Resource Planning)
-- ============================================================================


-- ============================================================================
-- CRM Tables
-- ============================================================================

-- Customer master information
DROP TABLE IF EXISTS bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_material_status VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE
);


-- Product master information
DROP TABLE IF EXISTS bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
    prd_id          INT,
    prd_key         VARCHAR(50),
    prd_name        VARCHAR(50),
    prd_cost        INT,
    prd_line        VARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE
);


-- Sales transaction details
DROP TABLE IF EXISTS bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);


-- ============================================================================
-- ERP Tables
-- ============================================================================

-- Customer location information
DROP TABLE IF EXISTS bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
    cid     VARCHAR(50),
    cntry   VARCHAR(50)
);


-- Customer demographic information
DROP TABLE IF EXISTS bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
    cid     VARCHAR(50),
    bdate   DATE,
    gen     VARCHAR(50)
);


-- Product category information
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id              VARCHAR(50),
    cat             VARCHAR(50),
    subcat          VARCHAR(50),
    maintenance     VARCHAR(50)
);