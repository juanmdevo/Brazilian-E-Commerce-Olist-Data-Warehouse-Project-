/*
=============================================================
Project: E-Commerce Data Warehouse Using Medallion Architecture
Dataset: Olist Brazilian E-Commerce Public Dataset
Script: 06_create_silver_tables.sql
Purpose: Create Silver Layer tables for cleaned and standardized data.
Layer: Silver
=============================================================

The Silver Layer contains cleaned, standardized, and validated data
created from the raw Bronze Layer tables.

Main improvements in Silver:
- Standardized table names
- Cleaner column names
- Corrected spelling issues
- Standardized text fields
- Added derived business columns
- Added data quality flags
- Prepared data for Gold Layer modeling
=============================================================
*/

-- =============================================================
-- Drop existing Silver tables if they already exist
-- =============================================================

DROP TABLE IF EXISTS silver.order_payments;
DROP TABLE IF EXISTS silver.order_reviews;
DROP TABLE IF EXISTS silver.order_items;
DROP TABLE IF EXISTS silver.orders;
DROP TABLE IF EXISTS silver.products;
DROP TABLE IF EXISTS silver.sellers;
DROP TABLE IF EXISTS silver.customers;
DROP TABLE IF EXISTS silver.geolocation;
DROP TABLE IF EXISTS silver.product_categories;

-- =============================================================
-- Create Silver Tables
-- =============================================================

-- =============================================================
-- 1. Customers
-- =============================================================

CREATE TABLE silver.customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);

-- =============================================================
-- 2. Orders
-- =============================================================

CREATE TABLE silver.orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT,
    order_status TEXT,
    order_status_group TEXT,

    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,

    order_purchase_date DATE,
    order_approved_date DATE,
    order_delivered_carrier_day DATE,
    order_delivered_customer_day DATE,
    order_estimated_delivery_day DATE,

    delivery_days INTEGER,
    estimated_delivery_days INTEGER,
    late_delivery_flag INTEGER,
    invalid_carrier_date_flag INTEGER,
    missing_delivery_date_flag INTEGER
);

-- =============================================================
-- 3. Order Items
-- =============================================================

CREATE TABLE silver.order_items (
    order_id TEXT,
    order_item_id INTEGER,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(12,2),
    freight_value NUMERIC(12,2),
    total_item_value NUMERIC(12,2),

    PRIMARY KEY (order_id, order_item_id)
);

-- =============================================================
-- 4. Order Payments
-- =============================================================

CREATE TABLE silver.order_payments (
    order_id TEXT,
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value NUMERIC(12,2),
    zero_payment_flag INTEGER,

    PRIMARY KEY (order_id, payment_sequential)
);

-- =============================================================
-- 5. Order Reviews
-- =============================================================

CREATE TABLE silver.order_reviews (
    review_id TEXT,
    order_id TEXT,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    review_creation_day DATE,
    review_answer_day DATE,
    review_score_group TEXT,

    PRIMARY KEY (review_id, order_id)
);

-- =============================================================
-- 6. Products
-- =============================================================

CREATE TABLE silver.products (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    product_category_name_english TEXT,

    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER,

    missing_category_flag INTEGER,
    missing_translation_flag INTEGER
);

-- =============================================================
-- 7. Sellers
-- =============================================================

CREATE TABLE silver.sellers (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city TEXT,
    seller_state TEXT
);

-- =============================================================
-- 8. Geolocation
-- =============================================================

CREATE TABLE silver.geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_city TEXT,
    geolocation_state TEXT,
    avg_latitude NUMERIC(12,8),
    avg_longitude NUMERIC(12,8),
    geolocation_record_count INTEGER,

    PRIMARY KEY (
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state
    )
);

-- =============================================================
-- 9. Product Categories
-- =============================================================

CREATE TABLE silver.product_categories (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT
);
