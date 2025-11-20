# SQL Inventory Management & Sales

A compact SQL-based Inventory & Sales Management demo.  
Includes schema, sample data, reporting queries, index suggestions and a stored procedure to demonstrate common OLTP operations and reporting for small projects.

## Repository contents

- `solution.sql`  
  SQL script to create schema (products, customers, orders, order_items), insert sample data, create useful indexes and a stored procedure `sp_get_monthly_sales`. Targeted at MySQL/MariaDB (minor changes required for PostgreSQL).

- `solution_description.txt`  
  Short human-readable description and usage notes.

## Features
- Schema design for products, customers, orders and order_items
- Transactional example for creating orders
- Reporting queries:
  - Daily sales summary
  - Top-selling products
  - Customer order history (JSON-aggregated)
- Index recommendations for performance
- Stored procedure `sp_get_monthly_sales(in_year)` to return monthly totals

## Prerequisites
- MySQL / MariaDB (or any RDBMS with minor syntax adjustments)
- MySQL client or GUI (MySQL Workbench, DBeaver, phpMyAdmin, etc.)

## How to run (MySQL / MariaDB)
1. Open your MySQL client and connect to the server.
2. Create a database (optional):
   ```sql
   CREATE DATABASE inventory_demo;
   USE inventory_demo;
