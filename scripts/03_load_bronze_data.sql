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

