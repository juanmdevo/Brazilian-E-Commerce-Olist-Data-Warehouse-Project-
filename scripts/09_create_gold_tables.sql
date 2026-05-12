/*
=============================================================
Project: E-Commerce Data Warehouse Using Medallion Architecture
Dataset: Olist Brazilian E-Commerce Public Dataset
Script: 09_create_gold_tables.sql
Purpose: Create Gold Layer fact and dimension tables for
         business-ready analytics and reporting.
Layer: Gold
=============================================================

The Gold Layer contains business-ready tables designed for reporting,
dashboarding, and analytical consumption.

Gold model:
- gold.dim_customers
- gold.dim_products
- gold.fact_sales

These tables will support Power BI reporting on sales performance,
delivery performance, customer satisfaction, product categories, and
regional analysis.
=============================================================
*/

-- =============================================================
-- Drop existing Gold tables if they already exist
-- =============================================================

DROP TABLE IF EXISTS gold.fact_sales;
DROP TABLE IF EXISTS gold.dim_customers;
DROP TABLE IF EXISTS gold.dim_products;

-- =============================================================
-- Create Gold Dimension: Customers
-- =============================================================

CREATE TABLE gold.dim_customers (
    customer_key SERIAL PRIMARY KEY,
    customer_id TEXT UNIQUE NOT NULL,
    customer_unique_id TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);

-- =============================================================
-- Create Gold Dimension: Products
-- =============================================================

CREATE TABLE gold.dim_products (
    product_key SERIAL PRIMARY KEY,
    product_id TEXT UNIQUE NOT NULL,
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
-- Create Gold Fact Table: Sales
-- =============================================================

CREATE TABLE gold.fact_sales (
    sales_key SERIAL PRIMARY KEY,

    -- Business keys
    order_id TEXT NOT NULL,
    order_item_id INTEGER NOT NULL,
    customer_id TEXT,
    product_id TEXT,
    seller_id TEXT,

    -- Dimension keys
    customer_key INTEGER,
    product_key INTEGER,

    -- Order fields
    order_status TEXT,
    order_status_group TEXT,
    order_purchase_date DATE,
    order_approved_date DATE,
    order_delivered_carrier_day DATE,
    order_delivered_customer_day DATE,
    order_estimated_delivery_day DATE,

    -- Sales metrics
    price NUMERIC(12,2),
    freight_value NUMERIC(12,2),
    total_item_value NUMERIC(12,2),

    -- Payment metrics
    payment_value NUMERIC(12,2),
    payment_type TEXT,
    payment_installments INTEGER,
    zero_payment_flag INTEGER,

    -- Review metrics
    review_score INTEGER,
    review_score_group TEXT,

    -- Delivery metrics
    delivery_days INTEGER,
    estimated_delivery_days INTEGER,
    late_delivery_flag INTEGER,
    invalid_carrier_date_flag INTEGER,
    missing_delivery_date_flag INTEGER,

    -- Product/category attributes for easier reporting
    product_category_name_english TEXT,

    -- Customer location attributes for easier reporting
    customer_city TEXT,
    customer_state TEXT,

    -- Seller location attributes
    seller_city TEXT,
    seller_state TEXT,

    -- Constraints
    CONSTRAINT fk_fact_sales_customer
        FOREIGN KEY (customer_key)
        REFERENCES gold.dim_customers(customer_key),

    CONSTRAINT fk_fact_sales_product
        FOREIGN KEY (product_key)
        REFERENCES gold.dim_products(product_key)
);
