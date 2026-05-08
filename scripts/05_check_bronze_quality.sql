/*
=============================================================
Project: E-Commerce Data Warehouse Using Medallion Architecture
Dataset: Olist Brazilian E-Commerce Public Dataset
Script: 05_check_bronze_quality.sql
Purpose: Analyze Bronze Layer data quality before building
         the Silver Layer.
Layer: Bronze
=============================================================

This script checks:
- Row counts
- Duplicate keys
- Null values
- Missing category translations
- Invalid date logic
- Negative or zero business values
- Geolocation duplicates
- Review score validity
=============================================================
*/

-- =============================================================
-- 1. Bronze table row counts
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
-- 2. Duplicate key checks
-- =============================================================

-- Customers: customer_id should be unique
SELECT 
    customer_id,
    COUNT(*) AS duplicate_count
FROM bronze.olist_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Orders: order_id should be unique
SELECT 
    order_id,
    COUNT(*) AS duplicate_count
FROM bronze.olist_orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Products: product_id should be unique
SELECT 
    product_id,
    COUNT(*) AS duplicate_count
FROM bronze.olist_products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- Sellers: seller_id should be unique
SELECT 
    seller_id,
    COUNT(*) AS duplicate_count
FROM bronze.olist_sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- Product category translation: product_category_name should be unique
SELECT 
    product_category_name,
    COUNT(*) AS duplicate_count
FROM bronze.product_category_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;

-- =============================================================
-- 3. Null checks in critical columns
-- =============================================================

SELECT 'customers.customer_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_customers
WHERE customer_id IS NULL

UNION ALL

SELECT 'customers.customer_unique_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_customers
WHERE customer_unique_id IS NULL

UNION ALL

SELECT 'orders.order_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_orders
WHERE order_id IS NULL

UNION ALL

SELECT 'orders.customer_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_orders
WHERE customer_id IS NULL

UNION ALL

SELECT 'orders.order_status' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_orders
WHERE order_status IS NULL

UNION ALL

SELECT 'order_items.order_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_items
WHERE order_id IS NULL

UNION ALL

SELECT 'order_items.product_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_items
WHERE product_id IS NULL

UNION ALL

SELECT 'order_items.seller_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_items
WHERE seller_id IS NULL

UNION ALL

SELECT 'order_items.price' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_items
WHERE price IS NULL

UNION ALL

SELECT 'order_items.freight_value' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_items
WHERE freight_value IS NULL

UNION ALL

SELECT 'payments.order_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_payments
WHERE order_id IS NULL

UNION ALL

SELECT 'payments.payment_type' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_payments
WHERE payment_type IS NULL

UNION ALL

SELECT 'payments.payment_value' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_payments
WHERE payment_value IS NULL

UNION ALL

SELECT 'reviews.order_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_reviews
WHERE order_id IS NULL

UNION ALL

SELECT 'reviews.review_score' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_order_reviews
WHERE review_score IS NULL

UNION ALL

SELECT 'products.product_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_products
WHERE product_id IS NULL

UNION ALL

SELECT 'products.product_category_name' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_products
WHERE product_category_name IS NULL

UNION ALL

SELECT 'sellers.seller_id' AS column_checked, COUNT(*) AS null_count
FROM bronze.olist_sellers
WHERE seller_id IS NULL

ORDER BY column_checked;

-- =============================================================
-- 4. Missing product category translations
-- =============================================================

-- Count product records without category translation
SELECT 
    COUNT(*) AS products_without_category_translation
FROM bronze.olist_products p
LEFT JOIN bronze.product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;


-- Show distinct category names missing translation
SELECT DISTINCT
    p.product_category_name
FROM bronze.olist_products p
LEFT JOIN bronze.product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL
ORDER BY p.product_category_name;


-- Show product count by missing category
SELECT 
    p.product_category_name,
    COUNT(*) AS product_count
FROM bronze.olist_products p
LEFT JOIN bronze.product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL
GROUP BY p.product_category_name
ORDER BY product_count DESC;

-- =============================================================
-- 5. Order date quality checks
-- =============================================================

-- Overall order date range
SELECT
    MIN(order_purchase_timestamp) AS first_order_date,
    MAX(order_purchase_timestamp) AS last_order_date
FROM bronze.olist_orders;


-- Orders where approval date is before purchase date
SELECT 
    COUNT(*) AS approval_before_purchase_count
FROM bronze.olist_orders
WHERE order_approved_at < order_purchase_timestamp;


-- Orders where carrier delivery date is before purchase date
SELECT 
    COUNT(*) AS carrier_date_before_purchase_count
FROM bronze.olist_orders
WHERE order_delivered_carrier_date < order_purchase_timestamp;


-- Orders where customer delivery date is before purchase date
SELECT 
    COUNT(*) AS customer_delivery_before_purchase_count
FROM bronze.olist_orders
WHERE order_delivered_customer_date < order_purchase_timestamp;


-- Delivered orders missing customer delivery date
SELECT 
    COUNT(*) AS delivered_orders_missing_customer_delivery_date
FROM bronze.olist_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;


-- Orders delivered after estimated delivery date
SELECT 
    COUNT(*) AS late_delivered_orders
FROM bronze.olist_orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;

/*
=============================================================
Order Date Quality Findings
=============================================================

Order date quality checks confirmed that the dataset covers orders 
from 2016-09-04 to 2018-10-17.

No approval dates or customer delivery dates occurred before purchase 
timestamps.

However, 166 records had carrier delivery dates before the purchase 
timestamp, and 8 delivered orders were missing customer delivery dates.

These issues will be handled in the Silver Layer through data quality 
flags and cleaned date logic.

Additionally, 7,827 orders were delivered after the estimated delivery 
date, which will be used later as a delivery performance metric.
=============================================================
*/

-- =============================================================
-- 6. Business value checks: price, freight, payments
-- =============================================================

-- Price and freight summary
SELECT 
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    MIN(freight_value) AS min_freight_value,
    MAX(freight_value) AS max_freight_value,
    AVG(freight_value) AS avg_freight_value
FROM bronze.olist_order_items;


-- Orders with negative price or freight
SELECT 
    COUNT(*) AS negative_price_or_freight_count
FROM bronze.olist_order_items
WHERE price < 0
   OR freight_value < 0;


-- Orders with zero price
SELECT 
    COUNT(*) AS zero_price_count
FROM bronze.olist_order_items
WHERE price = 0;


-- Payment value summary
SELECT 
    MIN(payment_value) AS min_payment_value,
    MAX(payment_value) AS max_payment_value,
    AVG(payment_value) AS avg_payment_value
FROM bronze.olist_order_payments;


-- Payments with negative value
SELECT 
    COUNT(*) AS negative_payment_value_count
FROM bronze.olist_order_payments
WHERE payment_value < 0;


-- Payments with zero value
SELECT 
    COUNT(*) AS zero_payment_value_count
FROM bronze.olist_order_payments
WHERE payment_value = 0;

/*
=============================================================
Price, Freight, and Payment Quality Findings
=============================================================

Price and freight quality checks confirmed that no order items had
negative price values, negative freight values, or zero price values.

Payment quality checks confirmed that no payments had negative payment
values. However, 9 records had a payment value of zero.

These zero-payment records will be reviewed and handled in the Silver
Layer through a data quality flag to preserve traceability while allowing
accurate reporting logic in the Gold Layer.
=============================================================
*/

-- =============================================================
-- 7. Review score quality checks
-- =============================================================

-- Review score range
SELECT
    MIN(review_score) AS min_review_score,
    MAX(review_score) AS max_review_score,
    AVG(review_score) AS avg_review_score
FROM bronze.olist_order_reviews;


-- Invalid review scores outside expected 1-5 range
SELECT 
    COUNT(*) AS invalid_review_score_count
FROM bronze.olist_order_reviews
WHERE review_score < 1
   OR review_score > 5;


-- Review score distribution
SELECT
    review_score,
    COUNT(*) AS review_count
FROM bronze.olist_order_reviews
GROUP BY review_score
ORDER BY review_score;

-- =============================================================
-- 8. Geolocation duplicate checks
-- =============================================================

-- Total geolocation rows vs distinct zip code prefixes
SELECT
    COUNT(*) AS total_geolocation_rows,
    COUNT(DISTINCT geolocation_zip_code_prefix) AS distinct_zip_code_prefixes
FROM bronze.olist_geolocation;


-- Zip code prefixes with multiple records
SELECT
    geolocation_zip_code_prefix,
    COUNT(*) AS record_count
FROM bronze.olist_geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1
ORDER BY record_count DESC
LIMIT 20;

/*
=============================================================
Geolocation Quality Findings
=============================================================

The geolocation table contains 1,000,163 raw records but only 19,015
distinct zip code prefixes. Several zip code prefixes appear hundreds
or thousands of times, which indicates that the raw geolocation source
contains repeated location records.

This is expected for the raw Bronze Layer and will be handled in the
Silver Layer by creating a standardized geolocation reference table.
The Silver table will aggregate latitude and longitude values and
standardize city and state fields for analytical use.
=============================================================
*/

-- =============================================================
-- 9. Order status distribution
-- =============================================================

SELECT
    order_status,
    COUNT(*) AS order_count
FROM bronze.olist_orders
GROUP BY order_status
ORDER BY order_count DESC;

/*
=============================================================
Order Status Quality Findings
=============================================================

Order status validation identified 8 distinct order statuses in the
Bronze orders table. The values are consistently formatted in lowercase
and do not require text standardization.

Most orders were delivered, with 96,478 records marked as delivered.
Other statuses include shipped, canceled, unavailable, invoiced,
processing, created, and approved.

In the Silver Layer, the original order_status field will be preserved,
and a derived order_status_group field may be created to simplify
reporting and dashboard analysis.
=============================================================
*/

