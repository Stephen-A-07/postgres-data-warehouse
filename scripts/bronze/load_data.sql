-- ============================================================================
-- Bronze Layer Data Loading
-- ============================================================================
-- Purpose:
-- Load raw CSV files into the Bronze layer tables.
--
-- Source Systems:
--   • CRM (Customer Relationship Management)
--   • ERP (Enterprise Resource Planning)
--
-- Notes:
--   • Files are loaded exactly as received from the source systems.
--   • No data cleansing or transformations are performed at this stage.
--   • CSV files contain a header row.
-- ============================================================================


-- ============================================================================
-- Load CRM Data
-- ============================================================================

-- Load customer master data
COPY bronze.crm_cust_info
FROM 'D:/postgres-data-warehouse/datasets/source_crm/cust_info.csv'
DELIMITER ','
CSV HEADER;


-- Load product master data
COPY bronze.crm_prd_info
FROM 'D:/postgres-data-warehouse/datasets/source_crm/prd_info.csv'
DELIMITER ','
CSV HEADER;


-- Load sales transaction data
COPY bronze.crm_sales_details
FROM 'D:/postgres-data-warehouse/datasets/source_crm/sales_details.csv'
DELIMITER ','
CSV HEADER;


-- ============================================================================
-- Load ERP Data
-- ============================================================================

-- Load customer demographic information
COPY bronze.erp_cust_az12
FROM 'D:/postgres-data-warehouse/datasets/source_erp/CUST_AZ12.csv'
DELIMITER ','
CSV HEADER;


-- Load customer location information
COPY bronze.erp_loc_a101
FROM 'D:/postgres-data-warehouse/datasets/source_erp/loc_a101.csv'
DELIMITER ','
CSV HEADER;


-- Load product category information
COPY bronze.erp_px_cat_g1v2
FROM 'D:/postgres-data-warehouse/datasets/source_erp/px_cat_g1v2.csv'
DELIMITER ','
CSV HEADER;