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
