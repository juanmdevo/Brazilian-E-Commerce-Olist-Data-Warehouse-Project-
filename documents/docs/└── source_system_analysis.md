# Source System Analysis

This document describes the raw source files used for the Olist E-Commerce Data Warehouse project. The dataset contains 9 CSV files representing customer, order, product, seller, payment, review, and reference data.

## Source Systems

| Source System | File Name | Business Area | Purpose |
|---|---|---|---|
| CRM | olist_customers_dataset.csv | Customers | Customer profile and location data |
| CRM | olist_orders_dataset.csv | Orders | Order status and delivery timestamps |
| CRM | olist_order_reviews_dataset.csv | Reviews | Customer satisfaction and review data |
| ERP | olist_products_dataset.csv | Products | Product master data |
| ERP | olist_sellers_dataset.csv | Sellers | Seller/vendor location data |
| ERP | olist_order_items_dataset.csv | Order Items | Product-level transaction data |
| Payments | olist_order_payments_dataset.csv | Payments | Payment method and payment value data |
| Reference | olist_geolocation_dataset.csv | Geolocation | Zip code, city, state, latitude, and longitude data |
| Reference | product_category_name_translation.csv | Product Category Translation | Portuguese-to-English product category mapping |

## Main Relationships

- customers.customer_id connects to orders.customer_id
- orders.order_id connects to order_items.order_id
- orders.order_id connects to order_payments.order_id
- orders.order_id connects to order_reviews.order_id
- order_items.product_id connects to products.product_id
- order_items.seller_id connects to sellers.seller_id
- products.product_category_name connects to product_category_translation.product_category_name
- customers.customer_zip_code_prefix connects to geolocation.geolocation_zip_code_prefix
- sellers.seller_zip_code_prefix connects to geolocation.geolocation_zip_code_prefix
