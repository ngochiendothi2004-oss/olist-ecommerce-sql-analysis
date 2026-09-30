-- =====================================================
-- 02_import_data.sql
-- Data import notes and validation
-- =====================================================
-- Source: Brazilian E-Commerce Public Dataset by Olist (Kaggle)
-- Method: MySQL Workbench Table Data Import Wizard
--         (right-click table > Table Data Import Wizard > Use existing table)
-- Import order (parent tables first, because of foreign keys):
--   1. customers
--   2. sellers
--   3. products
--   4. product_category_translation
--   5. orders
--   6. order_items
--   7. order_payments
--   8. order_reviews
--   9. geolocation (skip)

USE olist_ecommerce;

-- Validation: row counts after import
SELECT 'customers' AS tbl, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'product_category_translation', COUNT(*) FROM product_category_translation
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
-- UNION ALL SELECT 'geolocation', COUNT(*) FROM geolocation;