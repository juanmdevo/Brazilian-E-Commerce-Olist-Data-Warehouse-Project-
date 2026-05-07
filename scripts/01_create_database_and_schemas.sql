/*
=============================================================
Project: E-Commerce Data Warehouse Using Medallion Architecture
Dataset: Olist Brazilian E-Commerce Public Dataset
Script: 01_create_database_and_schemas.sql
Purpose: Create the PostgreSQL database and schemas for the
         Bronze, Silver, and Gold data warehouse layers.
=============================================================
*/

-- Create database
-- Note: Run this command first while connected to the default postgres database.
CREATE DATABASE olist_ecommerce_dw;


-- After creating the database, connect to olist_ecommerce_dw
-- Then run the schema creation commands below.

-- Create Bronze schema
CREATE SCHEMA IF NOT EXISTS bronze;

-- Create Silver schema
CREATE SCHEMA IF NOT EXISTS silver;

-- Create Gold schema
CREATE SCHEMA IF NOT EXISTS gold;


-- Add schema descriptions
COMMENT ON SCHEMA bronze IS 
'Raw source data loaded from Olist CSV files with minimal transformation.';

COMMENT ON SCHEMA silver IS 
'Cleaned, standardized, and validated data prepared for analytical modeling.';

COMMENT ON SCHEMA gold IS 
'Business-ready fact tables, dimension tables, and reporting views for BI and analytics.';


-- Verify schemas were created
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('bronze', 'silver', 'gold')
ORDER BY schema_name;
