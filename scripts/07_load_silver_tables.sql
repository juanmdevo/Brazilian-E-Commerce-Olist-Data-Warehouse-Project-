/*
=============================================================
Project: E-Commerce Data Warehouse Using Medallion Architecture
Dataset: Olist Brazilian E-Commerce Public Dataset
Script: 07_load_silver_tables.sql
Purpose: Transform and load cleaned Bronze data into Silver tables.
Layer: Silver
=============================================================

This script:
- Truncates Silver tables before loading
- Cleans and standardizes Bronze data
- Applies data quality rules identified during Bronze profiling
- Adds derived columns and quality flags
- Prepares Silver tables for Gold Layer modeling
=============================================================
*/

-- =============================================================
-- 1. Clear existing Silver data
-- =============================================================

TRUNCATE TABLE silver.order_payments;
TRUNCATE TABLE silver.order_reviews;
TRUNCATE TABLE silver.order_items;
TRUNCATE TABLE silver.orders;
TRUNCATE TABLE silver.products;
TRUNCATE TABLE silver.sellers;
TRUNCATE TABLE silver.customers;
TRUNCATE TABLE silver.geolocation;
TRUNCATE TABLE silver.product_categories;

-- =============================================================
-- 2. Load silver.customers
-- =============================================================

INSERT INTO silver.customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    INITCAP(TRIM(customer_city)) AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
FROM bronze.olist_customers;

/*
Customer Cleaning Rule:
Customer city values were trimmed and converted to title case.
Customer state values were trimmed and converted to uppercase.
Customer IDs and zip code prefixes were preserved from the Bronze Layer.
*/

-- =============================================================
-- 3. Load silver.product_categories
-- =============================================================

INSERT INTO silver.product_categories (
    product_category_name,
    product_category_name_english
)
SELECT
    TRIM(product_category_name) AS product_category_name,
    INITCAP(REPLACE(TRIM(product_category_name_english), '_', ' ')) AS product_category_name_english
FROM bronze.product_category_translation;

-- =============================================================
-- 4. Load silver.products
-- =============================================================

INSERT INTO silver.products (
    product_id,
    product_category_name,
    product_category_name_english,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    missing_category_flag,
    missing_translation_flag
)
SELECT
    p.product_id,

    -- Keep original category, but replace missing values with 'Unknown'
    COALESCE(TRIM(p.product_category_name), 'Unknown') AS product_category_name,

    -- Use English translation when available.
    -- If translation is missing, use original Portuguese category.
    -- If original category is missing, use 'Unknown'.
    COALESCE(
        INITCAP(REPLACE(TRIM(t.product_category_name_english), '_', ' ')),
        TRIM(p.product_category_name),
        'Unknown'
    ) AS product_category_name_english,

    -- Fix original Olist spelling issue: lenght → length
    p.product_name_lenght AS product_name_length,
    p.product_description_lenght AS product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,

    -- Data quality flags
    CASE
        WHEN p.product_category_name IS NULL THEN 1
        ELSE 0
    END AS missing_category_flag,

    CASE
        WHEN p.product_category_name IS NOT NULL
             AND t.product_category_name_english IS NULL THEN 1
        ELSE 0
    END AS missing_translation_flag

FROM bronze.olist_products p
LEFT JOIN bronze.product_category_translation t
    ON p.product_category_name = t.product_category_name;

/*
=============================================================
Product Category Cleaning Findings
=============================================================

The Silver products table successfully handled product category data
quality issues identified in the Bronze Layer.

610 products with missing product_category_name values were assigned
a standardized category value of 'Unknown' and flagged using
missing_category_flag = 1.

13 products with product categories missing English translations were
preserved using the original Portuguese category name and flagged using
missing_translation_flag = 1.

The Bronze source spelling issue in product_name_lenght and
product_description_lenght was corrected in Silver as
product_name_length and product_description_length.
=============================================================
*/

-- =============================================================
-- 5. Load silver.orders
-- =============================================================

INSERT INTO silver.orders (
    order_id,
    customer_id,
    order_status,
    order_status_group,

    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    order_purchase_date,
    order_approved_date,
    order_delivered_carrier_day,
    order_delivered_customer_day,
    order_estimated_delivery_day,

    delivery_days,
    estimated_delivery_days,
    late_delivery_flag,
    invalid_carrier_date_flag,
    missing_delivery_date_flag
)
SELECT
    order_id,
    customer_id,
    TRIM(order_status) AS order_status,

    CASE
        WHEN order_status = 'delivered' THEN 'Completed'
        WHEN order_status IN ('shipped', 'invoiced', 'processing', 'approved', 'created') THEN 'In Progress'
        WHEN order_status = 'canceled' THEN 'Canceled'
        WHEN order_status = 'unavailable' THEN 'Unavailable'
        ELSE 'Other'
    END AS order_status_group,

    order_purchase_timestamp,
    order_approved_at,

    CASE
        WHEN order_delivered_carrier_date < order_purchase_timestamp THEN NULL
        ELSE order_delivered_carrier_date
    END AS order_delivered_carrier_date,

    order_delivered_customer_date,
    order_estimated_delivery_date,

    CAST(order_purchase_timestamp AS DATE) AS order_purchase_date,
    CAST(order_approved_at AS DATE) AS order_approved_date,

    CASE
        WHEN order_delivered_carrier_date < order_purchase_timestamp THEN NULL
        ELSE CAST(order_delivered_carrier_date AS DATE)
    END AS order_delivered_carrier_day,

    CAST(order_delivered_customer_date AS DATE) AS order_delivered_customer_day,
    CAST(order_estimated_delivery_date AS DATE) AS order_estimated_delivery_day,

    CASE
        WHEN order_delivered_customer_date IS NOT NULL
        THEN CAST(order_delivered_customer_date AS DATE) - CAST(order_purchase_timestamp AS DATE)
        ELSE NULL
    END AS delivery_days,

    CASE
        WHEN order_estimated_delivery_date IS NOT NULL
        THEN CAST(order_estimated_delivery_date AS DATE) - CAST(order_purchase_timestamp AS DATE)
        ELSE NULL
    END AS estimated_delivery_days,

    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
        ELSE 0
    END AS late_delivery_flag,

    CASE
        WHEN order_delivered_carrier_date < order_purchase_timestamp THEN 1
        ELSE 0
    END AS invalid_carrier_date_flag,

    CASE
        WHEN order_status = 'delivered'
             AND order_delivered_customer_date IS NULL THEN 1
        ELSE 0
    END AS missing_delivery_date_flag

FROM bronze.olist_orders;

/*
=============================================================
Order Date Cleaning Findings
=============================================================

The Silver orders table standardized order status values and created
business-friendly status groups for reporting.

166 records with carrier delivery dates before the purchase timestamp
were flagged with invalid_carrier_date_flag = 1. The cleaned carrier
delivery date field was set to NULL for those records to prevent invalid
date values from affecting downstream analysis.

8 delivered orders with missing customer delivery dates were flagged
with missing_delivery_date_flag = 1.

7,827 orders were flagged as late deliveries where the customer delivery
date occurred after the estimated delivery date.

Additional date-only fields and delivery duration metrics were created
to support Gold Layer modeling and Power BI reporting.
=============================================================
*/

-- =============================================================
-- 6. Load silver.order_payments
-- =============================================================

INSERT INTO silver.order_payments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value,
    zero_payment_flag
)
SELECT
    order_id,
    payment_sequential,
    LOWER(TRIM(payment_type)) AS payment_type,
    payment_installments,
    payment_value,

    CASE
        WHEN payment_value = 0 THEN 1
        ELSE 0
    END AS zero_payment_flag

FROM bronze.olist_order_payments;

/*
=============================================================
Payment Cleaning Findings
=============================================================

The Silver order_payments table standardized payment_type values and
preserved all payment records from the Bronze Layer.

No negative payment values were found in the Bronze quality checks.
However, 9 payment records had a payment_value of zero. These records
were retained and flagged using zero_payment_flag = 1 to preserve
traceability and support accurate downstream reporting decisions.

This allows the Gold Layer and Power BI reports to include or exclude
zero-payment records depending on the business metric being calculated.
=============================================================
*/

-- =============================================================
-- 7. Load silver.geolocation
-- =============================================================

INSERT INTO silver.geolocation (
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state,
    avg_latitude,
    avg_longitude,
    geolocation_record_count
)
SELECT
    geolocation_zip_code_prefix,
    INITCAP(TRIM(geolocation_city)) AS geolocation_city,
    UPPER(TRIM(geolocation_state)) AS geolocation_state,
    ROUND(AVG(geolocation_lat), 8) AS avg_latitude,
    ROUND(AVG(geolocation_lng), 8) AS avg_longitude,
    COUNT(*) AS geolocation_record_count
FROM bronze.olist_geolocation
GROUP BY
    geolocation_zip_code_prefix,
    INITCAP(TRIM(geolocation_city)),
    UPPER(TRIM(geolocation_state));

/*
=============================================================
Geolocation Cleaning Findings
=============================================================

The Bronze geolocation table contained 1,000,163 raw records and
19,015 distinct zip code prefixes, with many zip code prefixes appearing
multiple times.

The Silver geolocation table standardized city and state values and
aggregated repeated location records by zip code prefix, city, and state.

Average latitude and longitude values were created for each grouped
location, and geolocation_record_count was added to preserve visibility
into how many raw records contributed to each Silver location record.

This creates a cleaner reference table for downstream customer, seller,
regional, and delivery analysis.
=============================================================
*/

-- =============================================================
-- 8. Load silver.order_items
-- =============================================================

INSERT INTO silver.order_items (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    total_item_value
)
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    ROUND(price, 2) AS price,
    ROUND(freight_value, 2) AS freight_value,
    ROUND(price + freight_value, 2) AS total_item_value
FROM bronze.olist_order_items;

/*
=============================================================
Order Items Cleaning Findings
=============================================================

The Silver order_items table successfully loaded product-level order
transaction records from the Bronze Layer.

Bronze quality checks confirmed that order item records had no negative
prices, no negative freight values, no zero prices, and no missing values
in critical relationship keys such as order_id, product_id, and seller_id.

The Silver transformation preserved the original transaction fields and
added total_item_value, calculated as price plus freight_value. This
field will support downstream revenue, freight, and product performance
analysis in the Gold Layer.
=============================================================
*/

-- =============================================================
-- 9. Load silver.order_reviews
-- =============================================================

INSERT INTO silver.order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    review_creation_day,
    review_answer_day,
    review_score_group
)
SELECT
    review_id,
    order_id,
    review_score,
    TRIM(review_comment_title) AS review_comment_title,
    TRIM(review_comment_message) AS review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    CAST(review_creation_date AS DATE) AS review_creation_day,
    CAST(review_answer_timestamp AS DATE) AS review_answer_day,

    CASE
        WHEN review_score IN (1, 2) THEN 'Low Satisfaction'
        WHEN review_score = 3 THEN 'Neutral'
        WHEN review_score IN (4, 5) THEN 'High Satisfaction'
        ELSE 'Unknown'
    END AS review_score_group

FROM bronze.olist_order_reviews;

/*
=============================================================
Order Reviews Cleaning Findings
=============================================================

The Silver order_reviews table successfully loaded customer review
records from the Bronze Layer.

Review scores were validated in the Bronze quality checks and confirmed
to fall within the expected range of 1 to 5.

The Silver transformation preserved the original review_score and added
review_score_group to classify customer satisfaction into Low Satisfaction,
Neutral, and High Satisfaction categories.

Date-only fields were created from review_creation_date and
review_answer_timestamp to support time-based analysis in the Gold Layer
and Power BI dashboard.
=============================================================
*/

-- =============================================================
-- 10. Load silver.sellers
-- =============================================================

INSERT INTO silver.sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT
    seller_id,
    seller_zip_code_prefix,
    INITCAP(TRIM(seller_city)) AS seller_city,
    UPPER(TRIM(seller_state)) AS seller_state
FROM bronze.olist_sellers;

/*
=============================================================
Seller Standardization Findings
=============================================================

The Silver sellers table successfully loaded 3,095 seller records from
the Bronze Layer.

Seller city values were standardized using TRIM and INITCAP to improve
readability and consistency. Seller state values were standardized using
TRIM and UPPER.

Validation confirmed that seller_id values are complete and unique,
making the table ready for downstream seller and regional performance
analysis in the Gold Layer.
=============================================================
*/

-- =============================================================
-- 11. Final Silver Layer Row Count Validation
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
-- 12. Final Silver Layer Critical Key Null Checks
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
-- 13. Final Silver Layer Duplicate Key Checks
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
-- 14. Final Silver Layer Relationship Checks
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
-- 15. Final Silver Layer Data Quality Flag Summary
-- =============================================================

SELECT
    'products' AS table_name,
    SUM(missing_category_flag) AS issue_count,
    'Missing product category' AS issue_type
FROM silver.products

UNION ALL

SELECT
    'products' AS table_name,
    SUM(missing_translation_flag) AS issue_count,
    'Missing English category translation' AS issue_type
FROM silver.products

UNION ALL

SELECT
    'orders' AS table_name,
    SUM(invalid_carrier_date_flag) AS issue_count,
    'Invalid carrier date before purchase' AS issue_type
FROM silver.orders

UNION ALL

SELECT
    'orders' AS table_name,
    SUM(missing_delivery_date_flag) AS issue_count,
    'Delivered order missing customer delivery date' AS issue_type
FROM silver.orders

UNION ALL

SELECT
    'orders' AS table_name,
    SUM(late_delivery_flag) AS issue_count,
    'Late delivery' AS issue_type
FROM silver.orders

UNION ALL

SELECT
    'order_payments' AS table_name,
    SUM(zero_payment_flag) AS issue_count,
    'Zero payment value' AS issue_type
FROM silver.order_payments

ORDER BY table_name, issue_type;

-- =============================================================
-- 16. Final Silver Layer Business Field Checks
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


-- Product category flags
SELECT
    product_category_name_english,
    COUNT(*) AS product_count
FROM silver.products
GROUP BY product_category_name_english
ORDER BY product_count DESC
LIMIT 20;


-- Payment type distribution
SELECT
    payment_type,
    COUNT(*) AS payment_count
FROM silver.order_payments
GROUP BY payment_type
ORDER BY payment_count DESC;

/*
=============================================================
Final Silver Layer Validation Findings
=============================================================

The Silver Layer was successfully loaded and validated across all 9
cleaned tables: customers, orders, order_items, order_payments,
order_reviews, products, sellers, geolocation, and product_categories.

Row count validation confirmed that all expected records were loaded
from the Bronze Layer. The geolocation table was intentionally reduced
from 1,000,163 raw Bronze records to a cleaned reference table by grouping
zip code prefix, city, and state combinations.

Critical key validation confirmed that primary and relationship fields
are complete across the Silver Layer.

Duplicate key validation confirmed that major business keys are unique
where expected, including customer_id, order_id, product_id, seller_id,
product_category_name, order item keys, payment sequence keys, and review
keys.

Relationship validation confirmed that customers, orders, order items,
payments, reviews, products, and sellers are properly connected and ready
for Gold Layer modeling.

Data quality issues identified during Bronze profiling were preserved
using Silver flags, including missing product categories, missing English
category translations, invalid carrier dates, missing delivery dates,
late deliveries, and zero payment values.

The Silver Layer is now ready to support Gold Layer fact tables,
dimension tables, reporting views, and Power BI analytics.
=============================================================
*/
