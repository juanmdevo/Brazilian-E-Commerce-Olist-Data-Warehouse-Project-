/*
=============================================================
Project: E-Commerce Data Warehouse Using Medallion Architecture
Dataset: Olist Brazilian E-Commerce Public Dataset
Script: 08_validate_silver_layer.sql
Purpose: Validate Silver Layer data completeness, quality, and
         relationship integrity after transformation.
Layer: Silver
=============================================================

This script validates:
- Silver table row counts
- Critical key completeness
- Duplicate key checks
- Relationship integrity between Silver tables
- Data quality flag summaries
- Business field distributions
- Silver readiness for Gold Layer modeling
=============================================================
*/

-- =============================================================
-- 1. Silver table row count validation
-- =============================================================

SELECT 'silver.customers' AS table_name, COUNT(*) AS row_count
FROM silver.customers

UNION ALL

SELECT 'silver.geolocation' AS table_name, COUNT(*) AS row_count
FROM silver.geolocation

UNION ALL

SELECT 'silver.order_items' AS table_name, COUNT(*) AS row_count
FROM silver.order_items

UNION ALL

SELECT 'silver.order_payments' AS table_name, COUNT(*) AS row_count
FROM silver.order_payments

UNION ALL

SELECT 'silver.order_reviews' AS table_name, COUNT(*) AS row_count
FROM silver.order_reviews

UNION ALL

SELECT 'silver.orders' AS table_name, COUNT(*) AS row_count
FROM silver.orders

UNION ALL

SELECT 'silver.product_categories' AS table_name, COUNT(*) AS row_count
FROM silver.product_categories

UNION ALL

SELECT 'silver.products' AS table_name, COUNT(*) AS row_count
FROM silver.products

UNION ALL

SELECT 'silver.sellers' AS table_name, COUNT(*) AS row_count
FROM silver.sellers

ORDER BY table_name;

-- =============================================================
-- 2. Critical key null checks
-- =============================================================

SELECT 'customers.customer_id' AS column_checked, COUNT(*) AS null_count
FROM silver.customers
WHERE customer_id IS NULL

UNION ALL

SELECT 'orders.order_id' AS column_checked, COUNT(*) AS null_count
FROM silver.orders
WHERE order_id IS NULL

UNION ALL

SELECT 'orders.customer_id' AS column_checked, COUNT(*) AS null_count
FROM silver.orders
WHERE customer_id IS NULL

UNION ALL

SELECT 'order_items.order_id' AS column_checked, COUNT(*) AS null_count
FROM silver.order_items
WHERE order_id IS NULL

UNION ALL

SELECT 'order_items.product_id' AS column_checked, COUNT(*) AS null_count
FROM silver.order_items
WHERE product_id IS NULL

UNION ALL

SELECT 'order_items.seller_id' AS column_checked, COUNT(*) AS null_count
FROM silver.order_items
WHERE seller_id IS NULL

UNION ALL

SELECT 'order_payments.order_id' AS column_checked, COUNT(*) AS null_count
FROM silver.order_payments
WHERE order_id IS NULL

UNION ALL

SELECT 'order_reviews.order_id' AS column_checked, COUNT(*) AS null_count
FROM silver.order_reviews
WHERE order_id IS NULL

UNION ALL

SELECT 'products.product_id' AS column_checked, COUNT(*) AS null_count
FROM silver.products
WHERE product_id IS NULL

UNION ALL

SELECT 'sellers.seller_id' AS column_checked, COUNT(*) AS null_count
FROM silver.sellers
WHERE seller_id IS NULL

ORDER BY column_checked;

-- =============================================================
-- 3. Duplicate key checks
-- =============================================================

-- Customers: customer_id should be unique
SELECT 
    customer_id,
    COUNT(*) AS duplicate_count
FROM silver.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Orders: order_id should be unique
SELECT 
    order_id,
    COUNT(*) AS duplicate_count
FROM silver.orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Products: product_id should be unique
SELECT 
    product_id,
    COUNT(*) AS duplicate_count
FROM silver.products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- Sellers: seller_id should be unique
SELECT 
    seller_id,
    COUNT(*) AS duplicate_count
FROM silver.sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- Product categories: product_category_name should be unique
SELECT 
    product_category_name,
    COUNT(*) AS duplicate_count
FROM silver.product_categories
GROUP BY product_category_name
HAVING COUNT(*) > 1;


-- Order items: order_id + order_item_id should be unique
SELECT 
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM silver.order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;


-- Order payments: order_id + payment_sequential should be unique
SELECT 
    order_id,
    payment_sequential,
    COUNT(*) AS duplicate_count
FROM silver.order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;


-- Order reviews: review_id + order_id should be unique
SELECT 
    review_id,
    order_id,
    COUNT(*) AS duplicate_count
FROM silver.order_reviews
GROUP BY review_id, order_id
HAVING COUNT(*) > 1;

-- =============================================================
-- 4. Relationship integrity checks
-- =============================================================

-- Orders without matching customers
SELECT 
    COUNT(*) AS orders_without_matching_customer
FROM silver.orders o
LEFT JOIN silver.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Order items without matching orders
SELECT 
    COUNT(*) AS order_items_without_matching_order
FROM silver.order_items oi
LEFT JOIN silver.orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order payments without matching orders
SELECT 
    COUNT(*) AS payments_without_matching_order
FROM silver.order_payments p
LEFT JOIN silver.orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order reviews without matching orders
SELECT 
    COUNT(*) AS reviews_without_matching_order
FROM silver.order_reviews r
LEFT JOIN silver.orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order items without matching products
SELECT 
    COUNT(*) AS order_items_without_matching_product
FROM silver.order_items oi
LEFT JOIN silver.products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Order items without matching sellers
SELECT 
    COUNT(*) AS order_items_without_matching_seller
FROM silver.order_items oi
LEFT JOIN silver.sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- =============================================================
-- 5. Data quality flag summary
-- =============================================================

SELECT
    'products' AS table_name,
    'Missing product category' AS issue_type,
    SUM(missing_category_flag) AS issue_count
FROM silver.products

UNION ALL

SELECT
    'products' AS table_name,
    'Missing English category translation' AS issue_type,
    SUM(missing_translation_flag) AS issue_count
FROM silver.products

UNION ALL

SELECT
    'orders' AS table_name,
    'Invalid carrier date before purchase' AS issue_type,
    SUM(invalid_carrier_date_flag) AS issue_count
FROM silver.orders

UNION ALL

SELECT
    'orders' AS table_name,
    'Delivered order missing customer delivery date' AS issue_type,
    SUM(missing_delivery_date_flag) AS issue_count
FROM silver.orders

UNION ALL

SELECT
    'orders' AS table_name,
    'Late delivery' AS issue_type,
    SUM(late_delivery_flag) AS issue_count
FROM silver.orders

UNION ALL

SELECT
    'order_payments' AS table_name,
    'Zero payment value' AS issue_type,
    SUM(zero_payment_flag) AS issue_count
FROM silver.order_payments

ORDER BY table_name, issue_type;

-- =============================================================
-- 6. Business-ready field validation
-- =============================================================

-- Order status group distribution
SELECT
    order_status_group,
    COUNT(*) AS order_count
FROM silver.orders
GROUP BY order_status_group
ORDER BY order_count DESC;


-- Review score group distribution
SELECT
    review_score_group,
    COUNT(*) AS review_count
FROM silver.order_reviews
GROUP BY review_score_group
ORDER BY review_count DESC;


-- Payment type distribution
SELECT
    payment_type,
    COUNT(*) AS payment_count
FROM silver.order_payments
GROUP BY payment_type
ORDER BY payment_count DESC;


-- Top product categories by product count
SELECT
    product_category_name_english,
    COUNT(*) AS product_count
FROM silver.products
GROUP BY product_category_name_english
ORDER BY product_count DESC
LIMIT 20;

-- =============================================================
-- 7. Calculated field validation
-- =============================================================

-- Validate total_item_value calculation
SELECT
    COUNT(*) AS total_item_value_mismatch_count
FROM silver.order_items
WHERE total_item_value <> ROUND(price + freight_value, 2);


-- Validate invalid carrier date cleaning
SELECT
    COUNT(*) AS invalid_carrier_dates_remaining
FROM silver.orders
WHERE order_delivered_carrier_date < order_purchase_timestamp;


-- Validate late delivery flag logic
SELECT
    COUNT(*) AS late_delivery_flag_mismatch_count
FROM silver.orders
WHERE 
    (
        order_delivered_customer_date > order_estimated_delivery_date
        AND late_delivery_flag <> 1
    )
    OR
    (
        (order_delivered_customer_date <= order_estimated_delivery_date
         OR order_delivered_customer_date IS NULL
         OR order_estimated_delivery_date IS NULL)
        AND late_delivery_flag <> 0
    );


-- Validate zero payment flag logic
SELECT
    COUNT(*) AS zero_payment_flag_mismatch_count
FROM silver.order_payments
WHERE 
    (payment_value = 0 AND zero_payment_flag <> 1)
    OR
    (payment_value <> 0 AND zero_payment_flag <> 0);

