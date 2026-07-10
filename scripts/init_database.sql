-- ============================================================================
-- Database Initialization Script
-- Purpose:
--   1. Drop the existing DataWarehouse database (if it exists).
--   2. Create a fresh DataWarehouse database.
--   3. Create schemas for the Medallion Architecture:
--        - bronze : Raw data ingestion layer
--        - silver : Cleaned and transformed data
--        - gold   : Business-ready analytical data
-- ============================================================================

-- Drop the existing database to start with a clean environment.
DROP DATABASE IF EXISTS DataWarehouse;

-- Create a new Data Warehouse database.
CREATE DATABASE DataWarehouse;

-- ---------------------------------------------------------------------------
-- Connect to the DataWarehouse database before running the statements below.
-- PostgreSQL (psql):
--     \c DataWarehouse
--
-- pgAdmin:
--     Open the Query Tool for the DataWarehouse database.
-- ---------------------------------------------------------------------------

-- Create the Bronze schema for storing raw, unprocessed source data.
CREATE SCHEMA bronze;

-- Create the Silver schema for cleaned, validated, and transformed data.
CREATE SCHEMA silver;

-- Create the Gold schema for curated, business-ready data models.
CREATE SCHEMA gold;