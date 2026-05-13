# E-Commerce Data Warehouse Using Medallion Architecture
This project builds an end-to-end e-commerce data warehouse using the Olist Brazilian E-Commerce Public Dataset. The goal is to transform raw CSV files into a clean, validated, and business-ready data model that supports reporting and analytics.

The project follows a Bronze, Silver, and Gold architecture. Raw source data is first loaded into the Bronze Layer, then cleaned and standardized in the Silver Layer, and finally modeled into business-ready fact and dimension tables in the Gold Layer.

The final Gold Layer supports analysis of sales performance, product categories, delivery efficiency, customer satisfaction, seller performance, and regional business trends.

## Business Problem

An e-commerce company collects data from multiple operational systems, including customer records, orders, products, sellers, payments, reviews, and geolocation sources. However, the raw data is not ready for business reporting because it contains duplicated location records, missing product categories, missing translations, date inconsistencies, and other quality issues.

The business needs a structured data warehouse that turns raw operational data into clean, reliable, and analytics-ready datasets for decision-making.

## Project Objectives

The main objectives of this project are to:

- Design a PostgreSQL-based data warehouse using Bronze, Silver, and Gold layers
- Load raw Olist CSV files into the Bronze Layer
- Profile and validate raw source data quality
- Clean, standardize, and transform data into Silver tables
- Preserve known data quality issues using traceable flags
- Build Gold fact and dimension tables for business reporting
- Create Gold reporting views for Power BI analytics
- Document the full data warehouse process step by step

## Diagrams 
## Data Architecture
![Data Architecture](https://github.com/juanmdevo/Brazilian-E-Commerce-Olist-Data-Warehouse-Project-/blob/main/diagrams/Data%20Architecture.png)

## Data Flow
![Data Flow](https://github.com/juanmdevo/Brazilian-E-Commerce-Olist-Data-Warehouse-Project-/blob/main/diagrams/Data%20Flow.png)

## Integration Model
![Integration Model](https://github.com/juanmdevo/Brazilian-E-Commerce-Olist-Data-Warehouse-Project-/blob/main/diagrams/Integration%20Model.png)

## Star Schema
![Star Schema](https://github.com/juanmdevo/Brazilian-E-Commerce-Olist-Data-Warehouse-Project-/blob/main/diagrams/Star%20Schema.png)


## About Me 
I am an aspiring data analytics and data engineering professional focused on building business-ready data solutions. My portfolio projects combine SQL, PostgreSQL, data modeling, Power BI, and consulting-style analysis to turn raw data into actionable insights.

This project reflects my interest in data warehouse design, data quality, analytics engineering, and executive reporting. My goal is to continue developing technical and business problem-solving skills for data roles in corporate and consulting environments.

