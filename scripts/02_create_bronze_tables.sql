/*
=============================================================
Project: E-Commerce Data Warehouse Using Medallion Architecture
Dataset: Olist Brazilian E-Commerce Public Dataset
Script: 02_create_bronze_tables.sql
Purpose: Create Bronze Layer tables for raw Olist CSV data.
Created the initial Bronze Layer SQL script for the Olist e-commerce data warehouse. 
The script defines raw PostgreSQL tables for all 9 source CSV files while preserving the original source structure for traceability.
=============================================================
*/

-- Drop existing Bronze tables if they exist
DROP TABLE IF EXISTS bronze.olist_customers;
DROP TABLE IF EXISTS bronze.olist_geolocation;
DROP TABLE IF EXISTS bronze.olist_order_items;
DROP TABLE IF EXISTS bronze.olist_order_payments;
DROP TABLE IF EXISTS bronze.olist_order_reviews;
DROP TABLE IF EXISTS bronze.olist_orders;
DROP TABLE IF EXISTS bronze.olist_products;
DROP TABLE IF EXISTS bronze.olist_sellers;
DROP TABLE IF EXISTS bronze.product_category_translation;


-- Customers
CREATE TABLE bronze.olist_customers (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);


-- Geolocation
CREATE TABLE bronze.olist_geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat NUMERIC,
    geolocation_lng NUMERIC,
    geolocation_city TEXT,
    geolocation_state TEXT
);


-- Order Items
CREATE TABLE bronze.olist_order_items (
    order_id TEXT,
    order_item_id INTEGER,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC
);


-- Order Payments
CREATE TABLE bronze.olist_order_payments (
    order_id TEXT,
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value NUMERIC
);


-- Order Reviews
CREATE TABLE bronze.olist_order_reviews (
    review_id TEXT,
    order_id TEXT,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);


-- Orders
CREATE TABLE bronze.olist_orders (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);


-- Products
CREATE TABLE bronze.olist_products (
    product_id TEXT,
    product_category_name TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);


-- Sellers
CREATE TABLE bronze.olist_sellers (
    seller_id TEXT,
    seller_zip_code_prefix INTEGER,
    seller_city TEXT,
    seller_state TEXT
);


-- Product Category Translation
CREATE TABLE bronze.product_category_translation (
    product_category_name TEXT,
    product_category_name_english TEXT
);
