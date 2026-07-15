CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
BEGIN

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Starting Silver Layer Loading...';
    RAISE NOTICE '========================================';

    ------------------------------------------------------------------
    -- Load crm_cust_info
    ------------------------------------------------------------------
    RAISE NOTICE 'Loading silver.crm_cust_info...';

    TRUNCATE TABLE silver.crm_cust_info;

    INSERT INTO silver.crm_cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),

        CASE
            WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
            ELSE 'n/a'
        END,

        CASE
            WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
            ELSE 'n/a'
        END,

        cst_create_date
    FROM
    (
        SELECT *,
               ROW_NUMBER() OVER
               (
                   PARTITION BY cst_id
                   ORDER BY cst_create_date DESC
               ) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t
    WHERE flag_last = 1;

    RAISE NOTICE 'crm_cust_info loaded successfully.';


    ------------------------------------------------------------------
    -- Load crm_prd_info
    ------------------------------------------------------------------
    RAISE NOTICE 'Loading silver.crm_prd_info...';

    TRUNCATE TABLE silver.crm_prd_info;

    INSERT INTO silver.crm_prd_info
    (
        prd_id,
        cat_id,
        prd_key,
        prd_name,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key,1,5),'-','_'),
        SUBSTRING(prd_key,7),
        prd_name,
        COALESCE(prd_cost,0),

        CASE
            WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line))='S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
            ELSE 'n/a'
        END,

        prd_start_dt,

        LEAD(prd_start_dt)
        OVER
        (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        ) - 1

    FROM bronze.crm_prd_info;

    RAISE NOTICE 'crm_prd_info loaded successfully.';


    ------------------------------------------------------------------
    -- Load crm_sales_details
    ------------------------------------------------------------------
    RAISE NOTICE 'Loading silver.crm_sales_details...';

    TRUNCATE TABLE silver.crm_sales_details;

    INSERT INTO silver.crm_sales_details
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        CASE
            WHEN sls_order_dt = 0
                 OR LENGTH(sls_order_dt::TEXT) <> 8
            THEN NULL
            ELSE TO_DATE(sls_order_dt::TEXT,'YYYYMMDD')
        END,

        CASE
            WHEN sls_ship_dt = 0
                 OR LENGTH(sls_ship_dt::TEXT) <> 8
            THEN NULL
            ELSE TO_DATE(sls_ship_dt::TEXT,'YYYYMMDD')
        END,

        CASE
            WHEN sls_due_dt = 0
                 OR LENGTH(sls_due_dt::TEXT) <> 8
            THEN NULL
            ELSE TO_DATE(sls_due_dt::TEXT,'YYYYMMDD')
        END,

        CASE
            WHEN sls_sales IS NULL
                 OR sls_sales <= 0
                 OR sls_sales <> sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END,

        sls_quantity,

        CASE
            WHEN sls_price IS NULL
                 OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity,0)
            ELSE sls_price
        END

    FROM bronze.crm_sales_details;

    RAISE NOTICE 'crm_sales_details loaded successfully.';


    ------------------------------------------------------------------
    -- Load erp_cust_az12
    ------------------------------------------------------------------
    RAISE NOTICE 'Loading silver.erp_cust_az12...';

    TRUNCATE TABLE silver.erp_cust_az12;

    INSERT INTO silver.erp_cust_az12
    (
        cid,
        bdate,
        gen
    )
    SELECT

        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4)
            ELSE cid
        END,

        CASE
            WHEN bdate > CURRENT_DATE THEN NULL
            ELSE bdate
        END,

        CASE
            WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
            WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
            ELSE 'n/a'
        END

    FROM bronze.erp_cust_az12;

    RAISE NOTICE 'erp_cust_az12 loaded successfully.';


    ------------------------------------------------------------------
    -- Load erp_loc_a101
    ------------------------------------------------------------------
    RAISE NOTICE 'Loading silver.erp_loc_a101...';

    TRUNCATE TABLE silver.erp_loc_a101;

    INSERT INTO silver.erp_loc_a101
    (
        cid,
        cntry
    )
    SELECT

        REPLACE(cid,'-',''),

        CASE
            WHEN cntry='DE' THEN 'Germany'
            WHEN cntry IN ('US','USA') THEN 'United States'
            WHEN TRIM(COALESCE(cntry,''))='' THEN 'n/a'
            ELSE TRIM(cntry)
        END

    FROM bronze.erp_loc_a101;

    RAISE NOTICE 'erp_loc_a101 loaded successfully.';


    ------------------------------------------------------------------
    -- Load erp_px_cat_g1v2
    ------------------------------------------------------------------
    RAISE NOTICE 'Loading silver.erp_px_cat_g1v2...';

    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    INSERT INTO silver.erp_px_cat_g1v2
    (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT
        id,
        cat,
        subcat,
        maintenance
    FROM bronze.erp_px_cat_g1v2;

    RAISE NOTICE 'erp_px_cat_g1v2 loaded successfully.';

    ------------------------------------------------------------------
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Silver Layer Loaded Successfully.';
    RAISE NOTICE '========================================';

END;
$$;



--EXECUTE WITH
CALL silver.load_silver();