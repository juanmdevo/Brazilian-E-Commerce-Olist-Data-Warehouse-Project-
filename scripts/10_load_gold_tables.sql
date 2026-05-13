/*
=============================================================
Project: E-Commerce Data Warehouse Using Medallion Architecture
Dataset: Olist Brazilian E-Commerce Public Dataset
Script: 10_load_gold_tables.sql
Purpose: Load Gold Layer fact and dimension tables from the
         cleaned and validated Silver Layer.
Layer: Gold
=============================================================

The Gold Layer contains business-ready tables designed for reporting,
dashboarding, and analytical consumption.

This script:
- Clears existing Gold data
- Loads customer and product dimensions
- Loads the sales fact table
- Joins Silver tables into a business-ready analytical model
=============================================================
*/

-- =============================================================
-- 1. Clear existing Gold data
-- =============================================================

TRUNCATE TABLE gold.fact_sales RESTART IDENTITY;
TRUNCATE TABLE gold.dim_customers RESTART IDENTITY CASCADE;
TRUNCATE TABLE gold.dim_products RESTART IDENTITY CASCADE;

-- =============================================================
-- 2. Load Gold Dimension: Customers
-- =============================================================

INSERT INTO gold.dim_customers (
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
    customer_city,
    customer_state
FROM silver.customers;

-- =============================================================
-- 3. Load Gold Dimension: Products
-- =============================================================

INSERT INTO gold.dim_products (
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
FROM silver.products;

-- =============================================================
-- 4. Load Gold Fact Table: Sales
-- =============================================================

INSERT INTO gold.fact_sales (
    order_id,
    order_item_id,
    customer_id,
    product_id,
    seller_id,

    customer_key,
    product_key,

    order_status,
    order_status_group,
    order_purchase_date,
    order_approved_date,
    order_delivered_carrier_day,
    order_delivered_customer_day,
    order_estimated_delivery_day,

    price,
    freight_value,
    total_item_value,

    payment_value,
    payment_type,
    payment_installments,
    zero_payment_flag,

    review_score,
    review_score_group,

    delivery_days,
    estimated_delivery_days,
    late_delivery_flag,
    invalid_carrier_date_flag,
    missing_delivery_date_flag,

    product_category_name_english,

    customer_city,
    customer_state,

    seller_city,
    seller_state
)
SELECT
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,

    dc.customer_key,
    dp.product_key,

    o.order_status,
    o.order_status_group,
    o.order_purchase_date,
    o.order_approved_date,
    o.order_delivered_carrier_day,
    o.order_delivered_customer_day,
    o.order_estimated_delivery_day,

    oi.price,
    oi.freight_value,
    oi.total_item_value,

    pay.payment_value,
    pay.payment_type,
    pay.payment_installments,
    pay.zero_payment_flag,

    r.review_score,
    r.review_score_group,

    o.delivery_days,
    o.estimated_delivery_days,
    o.late_delivery_flag,
    o.invalid_carrier_date_flag,
    o.missing_delivery_date_flag,

    p.product_category_name_english,

    c.customer_city,
    c.customer_state,

    s.seller_city,
    s.seller_state

FROM silver.order_items oi

LEFT JOIN silver.orders o
    ON oi.order_id = o.order_id

LEFT JOIN silver.customers c
    ON o.customer_id = c.customer_id

LEFT JOIN silver.products p
    ON oi.product_id = p.product_id

LEFT JOIN silver.sellers s
    ON oi.seller_id = s.seller_id

LEFT JOIN gold.dim_customers dc
    ON o.customer_id = dc.customer_id

LEFT JOIN gold.dim_products dp
    ON oi.product_id = dp.product_id

LEFT JOIN (
    SELECT
        order_id,
        SUM(payment_value) AS payment_value,
        MAX(payment_type) AS payment_type,
        MAX(payment_installments) AS payment_installments,
        MAX(zero_payment_flag) AS zero_payment_flag
    FROM silver.order_payments
    GROUP BY order_id
) pay
    ON oi.order_id = pay.order_id

LEFT JOIN (
    SELECT
        order_id,
        AVG(review_score) AS review_score,
        MAX(review_score_group) AS review_score_group
    FROM silver.order_reviews
    GROUP BY order_id
) r
    ON oi.order_id = r.order_id;

-- =============================================================
-- 5. Gold row count validation
-- =============================================================

SELECT 'gold.dim_customers' AS table_name, COUNT(*) AS row_count
FROM gold.dim_customers

UNION ALL

SELECT 'gold.dim_products' AS table_name, COUNT(*) AS row_count
FROM gold.dim_products

UNION ALL

SELECT 'gold.fact_sales' AS table_name, COUNT(*) AS row_count
FROM gold.fact_sales

ORDER BY table_name;

-- =============================================================
-- 6. Validate fact table dimension keys
-- =============================================================

SELECT
    COUNT(*) FILTER (WHERE customer_key IS NULL) AS missing_customer_key_count,
    COUNT(*) FILTER (WHERE product_key IS NULL) AS missing_product_key_count
FROM gold.fact_sales;

-- =============================================================
-- 7. Validate fact sales metrics
-- =============================================================

SELECT
    COUNT(*) AS total_fact_rows,
    ROUND(SUM(price), 2) AS total_product_sales,
    ROUND(SUM(freight_value), 2) AS total_freight_value,
    ROUND(SUM(total_item_value), 2) AS total_item_value
FROM gold.fact_sales;


/*
=============================================================
Gold Layer Load Summary
=============================================================

The Gold Layer was successfully loaded from the cleaned and validated
Silver Layer.

gold.dim_customers contains customer attributes and location information.
gold.dim_products contains product and category attributes.
gold.fact_sales combines order item transactions with order, customer,
product, seller, payment, review, and delivery information.

The fact_sales table is designed as the main business-ready table for
Power BI reporting and analytics, supporting sales performance, delivery
performance, customer satisfaction, product category analysis, and
regional insights.
=============================================================
*/
