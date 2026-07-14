-- ============================================================================
-- Procedure: bronze.load_bronze()
-- ============================================================================
-- Purpose:
--     Perform a full refresh of all Bronze layer tables.
--
-- Process:
--     1. Truncate existing data.
--     2. Load the latest data from CSV files.
--
-- Usage:
--     CALL bronze.load_bronze();
-- ============================================================================

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
BEGIN

    RAISE NOTICE '==========================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '==========================================================';


    -- =======================================================================
    -- Load CRM Tables
    -- =======================================================================

    RAISE NOTICE '----------------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '----------------------------------------------------------';


    -- -----------------------------------------------------------------------
    -- CRM Customer Information
    -- -----------------------------------------------------------------------
    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';

    TRUNCATE TABLE bronze.crm_cust_info;

    RAISE NOTICE '>> Loading Data Into: bronze.crm_cust_info';

    COPY bronze.crm_cust_info
    FROM 'D:/postgres-data-warehouse/datasets/source_crm/cust_info.csv'
    DELIMITER ','
    CSV HEADER;


    -- -----------------------------------------------------------------------
    -- CRM Product Information
    -- -----------------------------------------------------------------------
    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';

    TRUNCATE TABLE bronze.crm_prd_info;

    RAISE NOTICE '>> Loading Data Into: bronze.crm_prd_info';

    COPY bronze.crm_prd_info
    FROM 'D:/postgres-data-warehouse/datasets/source_crm/prd_info.csv'
    DELIMITER ','
    CSV HEADER;


    -- -----------------------------------------------------------------------
    -- CRM Sales Details
    -- -----------------------------------------------------------------------
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';

    TRUNCATE TABLE bronze.crm_sales_details;

    RAISE NOTICE '>> Loading Data Into: bronze.crm_sales_details';

    COPY bronze.crm_sales_details
    FROM 'D:/postgres-data-warehouse/datasets/source_crm/sales_details.csv'
    DELIMITER ','
    CSV HEADER;



    -- =======================================================================
    -- Load ERP Tables
    -- =======================================================================

    RAISE NOTICE '----------------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '----------------------------------------------------------';


    -- -----------------------------------------------------------------------
    -- ERP Customer Information
    -- -----------------------------------------------------------------------
    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';

    TRUNCATE TABLE bronze.erp_cust_az12;

    RAISE NOTICE '>> Loading Data Into: bronze.erp_cust_az12';

    COPY bronze.erp_cust_az12
    FROM 'D:/postgres-data-warehouse/datasets/source_erp/CUST_AZ12.csv'
    DELIMITER ','
    CSV HEADER;


    -- -----------------------------------------------------------------------
    -- ERP Customer Location
    -- -----------------------------------------------------------------------
    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';

    TRUNCATE TABLE bronze.erp_loc_a101;

    RAISE NOTICE '>> Loading Data Into: bronze.erp_loc_a101';

    COPY bronze.erp_loc_a101
    FROM 'D:/postgres-data-warehouse/datasets/source_erp/loc_a101.csv'
    DELIMITER ','
    CSV HEADER;


    -- -----------------------------------------------------------------------
    -- ERP Product Categories
    -- -----------------------------------------------------------------------
    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';

    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    RAISE NOTICE '>> Loading Data Into: bronze.erp_px_cat_g1v2';

    COPY bronze.erp_px_cat_g1v2
    FROM 'D:/postgres-data-warehouse/datasets/source_erp/px_cat_g1v2.csv'
    DELIMITER ','
    CSV HEADER;


    RAISE NOTICE '==========================================================';
    RAISE NOTICE 'Bronze Layer Successfully Loaded';
    RAISE NOTICE '==========================================================';

END;
$$;

-- ============================================================================
-- Execute Procedure
-- ============================================================================
CALL bronze.load_bronze();