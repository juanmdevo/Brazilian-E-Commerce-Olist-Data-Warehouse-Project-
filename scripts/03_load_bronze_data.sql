/*
=============================================================
Project: E-Commerce Data Warehouse Using Medallion Architecture
Dataset: Olist Brazilian E-Commerce Public Dataset
Script: 03_load_bronze_data.sql
Purpose: Document and validate the Bronze Layer data load.
Method: Data was loaded manually using pgAdmin Import/Export Tool.
=============================================================

Import Settings Used:
- Format: CSV
- Header: Yes
- Delimiter: Comma (,)
- Encoding: UTF-8
- Import Mode: Import
- Target Schema: bronze

Source-to-Target Mapping:

1. olist_customers_dataset.csv
   -> bronze.olist_customers

2. olist_geolocation_dataset.csv
   -> bronze.olist_geolocation

3. olist_order_items_dataset.csv
   -> bronze.olist_order_items

4. olist_order_payments_dataset.csv
   -> bronze.olist_order_payments

5. olist_order_reviews_dataset.csv
   -> bronze.olist_order_reviews

6. olist_orders_dataset.csv
   -> bronze.olist_orders

7. olist_products_dataset.csv
   -> bronze.olist_products

8. olist_sellers_dataset.csv
   -> bronze.olist_sellers

9. product_category_name_translation.csv
   -> bronze.product_category_translation

Note:
The Bronze Layer stores raw source data with minimal transformation.
Column names and source structure are preserved to support traceability.
=============================================================
*/


-- =============================================================
-- Bronze Layer Row Count Validation
-- =============================================================

SELECT 'bronze.olist_customers' AS table_name, COUNT(*) AS row_count
FROM bronze.olist_customers

UNION ALL

SELECT 'bronze.olist_geolocation' AS table_name, COUNT(*) AS row_count
FROM bronze.olist_geolocation

UNION ALL

SELECT 'bronze.olist_order_items' AS table_name, COUNT(*) AS row_count
FROM bronze.olist_order_items

UNION ALL

SELECT 'bronze.olist_order_payments' AS table_name, COUNT(*) AS row_count
FROM bronze.olist_order_payments

UNION ALL

SELECT 'bronze.olist_order_reviews' AS table_name, COUNT(*) AS row_count
FROM bronze.olist_order_reviews

UNION ALL

SELECT 'bronze.olist_orders' AS table_name, COUNT(*) AS row_count
FROM bronze.olist_orders

UNION ALL

SELECT 'bronze.olist_products' AS table_name, COUNT(*) AS row_count
FROM bronze.olist_products

UNION ALL

SELECT 'bronze.olist_sellers' AS table_name, COUNT(*) AS row_count
FROM bronze.olist_sellers

UNION ALL

SELECT 'bronze.product_category_translation' AS table_name, COUNT(*) AS row_count
FROM bronze.product_category_translation

ORDER BY table_name;
