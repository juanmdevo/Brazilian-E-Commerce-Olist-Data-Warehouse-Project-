/*
=============================================================
Project: E-Commerce Data Warehouse Using Medallion Architecture
Dataset: Olist Brazilian E-Commerce Public Dataset
Script: 11_create_gold_views.sql
Purpose: Create Gold Layer reporting views for Power BI and
         business analytics.
Layer: Gold
=============================================================

The Gold reporting views provide business-ready aggregated datasets
for executive dashboards, sales analysis, delivery performance, and
customer satisfaction reporting.
=============================================================
*/

-- =============================================================
-- 1. Executive Summary View
-- =============================================================

DROP VIEW IF EXISTS gold.vw_executive_summary;

CREATE VIEW gold.vw_executive_summary AS
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_order_items,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT product_id) AS total_products,
    COUNT(DISTINCT seller_id) AS total_sellers,

    ROUND(SUM(price), 2) AS total_product_sales,
    ROUND(SUM(freight_value), 2) AS total_freight_value,
    ROUND(SUM(total_item_value), 2) AS total_revenue_with_freight,

    ROUND(AVG(price), 2) AS avg_item_price,
    ROUND(AVG(freight_value), 2) AS avg_freight_value,
    ROUND(AVG(total_item_value), 2) AS avg_item_value,

    ROUND(SUM(total_item_value) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS avg_order_value,

    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,

    SUM(late_delivery_flag) AS late_deliveries,
    ROUND(
        SUM(late_delivery_flag)::NUMERIC / NULLIF(COUNT(DISTINCT order_id), 0) * 100,
        2
    ) AS late_delivery_rate_pct,

    SUM(zero_payment_flag) AS zero_payment_records,
    SUM(missing_delivery_date_flag) AS missing_delivery_date_records,
    SUM(invalid_carrier_date_flag) AS invalid_carrier_date_records

FROM gold.fact_sales;

/*
=============================================================
Executive Summary View
=============================================================

gold.vw_executive_summary provides high-level business KPIs for the
Power BI Executive Overview page.

The view summarizes total orders, customers, products, sellers, sales,
freight, total revenue with freight, average order value, review score,
delivery time, late delivery rate, and key data quality indicators.

This view is designed for executive-level reporting and quick business
performance monitoring.
=============================================================
*/

-- =============================================================
-- 2. Sales by Product Category View
-- =============================================================

DROP VIEW IF EXISTS gold.vw_sales_by_category;

CREATE VIEW gold.vw_sales_by_category AS
SELECT
    product_category_name_english,

    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_order_items,
    COUNT(DISTINCT product_id) AS total_products,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT seller_id) AS total_sellers,

    ROUND(SUM(price), 2) AS total_product_sales,
    ROUND(SUM(freight_value), 2) AS total_freight_value,
    ROUND(SUM(total_item_value), 2) AS total_revenue_with_freight,

    ROUND(AVG(price), 2) AS avg_item_price,
    ROUND(AVG(freight_value), 2) AS avg_freight_value,
    ROUND(AVG(total_item_value), 2) AS avg_item_value,

    ROUND(SUM(total_item_value) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS avg_order_value,

    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,

    SUM(late_delivery_flag) AS late_deliveries,
    ROUND(
        SUM(late_delivery_flag)::NUMERIC / NULLIF(COUNT(DISTINCT order_id), 0) * 100,
        2
    ) AS late_delivery_rate_pct

FROM gold.fact_sales
GROUP BY product_category_name_english
ORDER BY total_revenue_with_freight DESC;

/*
=============================================================
Sales by Product Category View
=============================================================

gold.vw_sales_by_category provides category-level sales and performance
metrics for Power BI reporting.

The view summarizes total orders, order items, customers, sellers,
product sales, freight value, total revenue with freight, average order
value, average review score, average delivery days, and late delivery
rate by product category.

This view supports product performance analysis and helps identify the
highest-performing product categories by revenue, customer demand,
delivery efficiency, and customer satisfaction.
=============================================================
*/

-- =============================================================
-- 3. Delivery Performance View
-- =============================================================

DROP VIEW IF EXISTS gold.vw_delivery_performance;

CREATE VIEW gold.vw_delivery_performance AS
SELECT
    customer_state,
    seller_state,
    order_status_group,

    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_order_items,

    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(estimated_delivery_days), 2) AS avg_estimated_delivery_days,

    SUM(late_delivery_flag) AS late_deliveries,
    ROUND(
        SUM(late_delivery_flag)::NUMERIC / NULLIF(COUNT(DISTINCT order_id), 0) * 100,
        2
    ) AS late_delivery_rate_pct,

    SUM(invalid_carrier_date_flag) AS invalid_carrier_date_records,
    SUM(missing_delivery_date_flag) AS missing_delivery_date_records,

    ROUND(SUM(total_item_value), 2) AS total_revenue_with_freight,
    ROUND(AVG(review_score), 2) AS avg_review_score

FROM gold.fact_sales
GROUP BY
    customer_state,
    seller_state,
    order_status_group
ORDER BY late_delivery_rate_pct DESC;

/*
=============================================================
Delivery Performance View
=============================================================

gold.vw_delivery_performance provides delivery and fulfillment metrics
for Power BI reporting.

The view summarizes total orders, order items, average delivery days,
average estimated delivery days, late delivery counts, late delivery
rate, invalid carrier date records, missing delivery date records,
revenue, and average review score by customer state, seller state, and
order status group.

This view supports operational analysis by identifying regions and
seller/customer state combinations with higher delivery delays and
potential customer satisfaction impact.
=============================================================
*/

-- =============================================================
-- 4. Customer Satisfaction View
-- =============================================================

DROP VIEW IF EXISTS gold.vw_customer_satisfaction;

CREATE VIEW gold.vw_customer_satisfaction AS
SELECT
    review_score_group,
    product_category_name_english,
    customer_state,
    order_status_group,

    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_order_items,
    COUNT(DISTINCT customer_id) AS total_customers,

    ROUND(AVG(review_score), 2) AS avg_review_score,

    SUM(CASE WHEN review_score_group = 'High Satisfaction' THEN 1 ELSE 0 END) AS high_satisfaction_items,
    SUM(CASE WHEN review_score_group = 'Neutral' THEN 1 ELSE 0 END) AS neutral_satisfaction_items,
    SUM(CASE WHEN review_score_group = 'Low Satisfaction' THEN 1 ELSE 0 END) AS low_satisfaction_items,

    ROUND(
        SUM(CASE WHEN review_score_group = 'High Satisfaction' THEN 1 ELSE 0 END)::NUMERIC
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS high_satisfaction_rate_pct,

    ROUND(
        SUM(CASE WHEN review_score_group = 'Low Satisfaction' THEN 1 ELSE 0 END)::NUMERIC
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS low_satisfaction_rate_pct,

    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,

    SUM(late_delivery_flag) AS late_deliveries,

    ROUND(
        SUM(late_delivery_flag)::NUMERIC / NULLIF(COUNT(DISTINCT order_id), 0) * 100,
        2
    ) AS late_delivery_rate_pct,

    ROUND(SUM(total_item_value), 2) AS total_revenue_with_freight

FROM gold.fact_sales
WHERE review_score IS NOT NULL
GROUP BY
    review_score_group,
    product_category_name_english,
    customer_state,
    order_status_group
ORDER BY avg_review_score ASC;

/*
=============================================================
Customer Satisfaction View
=============================================================

gold.vw_customer_satisfaction provides customer review and satisfaction
metrics for Power BI reporting.

The view summarizes total orders, order items, customers, average review
score, satisfaction group counts, satisfaction rates, average delivery
days, late delivery rate, and revenue by review score group, product
category, customer state, and order status group.

This view supports analysis of how product category, delivery performance,
and customer region relate to customer satisfaction.
=============================================================
*/
