/*
=============================================================
Project: E-Commerce Data Warehouse Using Medallion Architecture
Dataset: Olist Brazilian E-Commerce Public Dataset
Script: 04_validate_bronze_layer.sql
Purpose: Validate Bronze Layer data completeness and schema checks.
Layer: Bronze
=============================================================
*/


-- =============================================================
-- 1. Validate row counts for all Bronze tables
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


-- =============================================================
-- 2. Validate expected Bronze tables exist
-- =============================================================

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'bronze'
ORDER BY table_name;


-- =============================================================
-- 3. Validate column counts by table
-- =============================================================

SELECT 
    table_schema,
    table_name,
    COUNT(column_name) AS column_count
FROM information_schema.columns
WHERE table_schema = 'bronze'
GROUP BY table_schema, table_name
ORDER BY table_name;


-- =============================================================
-- 4. Check null values in critical key columns
-- =============================================================

SELECT 'olist_customers.customer_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_customers
WHERE customer_id IS NULL

UNION ALL

SELECT 'olist_orders.order_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_orders
WHERE order_id IS NULL

UNION ALL

SELECT 'olist_orders.customer_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_orders
WHERE customer_id IS NULL

UNION ALL

SELECT 'olist_order_items.order_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_items
WHERE order_id IS NULL

UNION ALL

SELECT 'olist_order_items.product_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_items
WHERE product_id IS NULL

UNION ALL

SELECT 'olist_order_items.seller_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_items
WHERE seller_id IS NULL

UNION ALL

SELECT 'olist_order_payments.order_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_payments
WHERE order_id IS NULL

UNION ALL

SELECT 'olist_order_reviews.order_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_reviews
WHERE order_id IS NULL

UNION ALL

SELECT 'olist_products.product_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_products
WHERE product_id IS NULL

UNION ALL

SELECT 'olist_sellers.seller_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_sellers
WHERE seller_id IS NULL

ORDER BY column_checked;


-- =============================================================
-- 5. Check duplicate primary/business keys
-- =============================================================

-- Customers: customer_id should be unique
SELECT customer_id, COUNT(*) AS duplicate_count
FROM bronze.olist_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Orders: order_id should be unique
SELECT order_id, COUNT(*) AS duplicate_count
FROM bronze.olist_orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Products: product_id should be unique
SELECT product_id, COUNT(*) AS duplicate_count
FROM bronze.olist_products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- Sellers: seller_id should be unique
SELECT seller_id, COUNT(*) AS duplicate_count
FROM bronze.olist_sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- Category translation: product_category_name should be unique
SELECT product_category_name, COUNT(*) AS duplicate_count
FROM bronze.product_category_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;


-- =============================================================
-- 6. Check relationship completeness between major tables
-- =============================================================

-- Orders without matching customers
SELECT COUNT(*) AS orders_without_matching_customer
FROM bronze.olist_orders o
LEFT JOIN bronze.olist_customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Order items without matching orders
SELECT COUNT(*) AS order_items_without_matching_order
FROM bronze.olist_order_items oi
LEFT JOIN bronze.olist_orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order payments without matching orders
SELECT COUNT(*) AS payments_without_matching_order
FROM bronze.olist_order_payments p
LEFT JOIN bronze.olist_orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order reviews without matching orders
SELECT COUNT(*) AS reviews_without_matching_order
FROM bronze.olist_order_reviews r
LEFT JOIN bronze.olist_orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order items without matching products
SELECT COUNT(*) AS order_items_without_matching_product
FROM bronze.olist_order_items oi
LEFT JOIN bronze.olist_products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Order items without matching sellers
SELECT COUNT(*) AS order_items_without_matching_seller
FROM bronze.olist_order_items oi
LEFT JOIN bronze.olist_sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- Products without category translation
SELECT COUNT(*) AS products_without_category_translation
FROM bronze.olist_products p
LEFT JOIN bronze.product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;


-- =============================================================
-- 7. Check date ranges from order data
-- =============================================================

SELECT 
    MIN(order_purchase_timestamp) AS first_order_date,
    MAX(order_purchase_timestamp) AS last_order_date
FROM bronze.olist_orders;


-- =============================================================
-- 8. Check basic business value ranges
-- =============================================================

-- Check price and freight value ranges
SELECT 
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    MIN(freight_value) AS min_freight_value,
    MAX(freight_value) AS max_freight_value,
    AVG(freight_value) AS avg_freight_value
FROM bronze.olist_order_items;


-- Check payment value ranges
SELECT 
    MIN(payment_value) AS min_payment_value,
    MAX(payment_value) AS max_payment_value,
    AVG(payment_value) AS avg_payment_value
FROM bronze.olist_order_payments;


-- Check review score range
SELECT 
    MIN(review_score) AS min_review_score,
    MAX(review_score) AS max_review_score,
    AVG(review_score) AS avg_review_score
FROM bronze.olist_order_reviews;
