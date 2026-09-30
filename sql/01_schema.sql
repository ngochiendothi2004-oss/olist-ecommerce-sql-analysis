-- =====================================================
-- Olist E-Commerce Analysis: Database Schema (MySQL)
-- Run this whole script once, before importing the CSVs.
-- =====================================================

CREATE DATABASE IF NOT EXISTS olist_ecommerce
  DEFAULT CHARACTER SET utf8mb4;   -- utf8mb4 handles Portuguese accents

USE olist_ecommerce;

-- -----------------------------------------------------
-- 1. customers
-- customer_id is unique PER ORDER; customer_unique_id identifies the real person.
-- -----------------------------------------------------
CREATE TABLE customers (
    customer_id              VARCHAR(32)  NOT NULL,
    customer_unique_id       VARCHAR(32)  NOT NULL,
    customer_zip_code_prefix INT,
    customer_city            VARCHAR(100),
    customer_state           CHAR(2),
    PRIMARY KEY (customer_id),
    INDEX idx_customers_unique (customer_unique_id)
);

-- -----------------------------------------------------
-- 2. sellers
-- -----------------------------------------------------
CREATE TABLE sellers (
    seller_id              VARCHAR(32) NOT NULL,
    seller_zip_code_prefix INT,
    seller_city            VARCHAR(100),
    seller_state           CHAR(2),
    PRIMARY KEY (seller_id)
);

-- -----------------------------------------------------
-- 3. products
-- Note: "lenght" is misspelled in the original CSV. Keep it as is
-- so the import wizard matches the columns automatically.
-- -----------------------------------------------------
CREATE TABLE products (
    product_id                 VARCHAR(32) NOT NULL,
    product_category_name      VARCHAR(100),
    product_name_lenght        INT,
    product_description_lenght INT,
    product_photos_qty         INT,
    product_weight_g           INT,
    product_length_cm          INT,
    product_height_cm          INT,
    product_width_cm           INT,
    PRIMARY KEY (product_id),
    INDEX idx_products_category (product_category_name)
);

-- -----------------------------------------------------
-- 4. product_category_translation
-- Portuguese -> English category names.
-- No foreign key from products: some product categories are missing here.
-- -----------------------------------------------------
CREATE TABLE product_category_translation (
    product_category_name         VARCHAR(100) NOT NULL,
    product_category_name_english VARCHAR(100),
    PRIMARY KEY (product_category_name)
);

-- -----------------------------------------------------
-- 5. orders
-- Delivery dates are NULL for orders that were never delivered.
-- -----------------------------------------------------
CREATE TABLE orders (
    order_id                      VARCHAR(32) NOT NULL,
    customer_id                   VARCHAR(32) NOT NULL,
    order_status                  VARCHAR(20),
    order_purchase_timestamp      DATETIME NULL,
    order_approved_at             DATETIME NULL,
    order_delivered_carrier_date  DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NULL,
    PRIMARY KEY (order_id),
    INDEX idx_orders_purchase (order_purchase_timestamp),
    INDEX idx_orders_status (order_status),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);

-- -----------------------------------------------------
-- 6. order_items
-- One row per item in an order.
-- -----------------------------------------------------
CREATE TABLE order_items (
    order_id            VARCHAR(32) NOT NULL,
    order_item_id       INT         NOT NULL,
    product_id          VARCHAR(32) NOT NULL,
    seller_id           VARCHAR(32) NOT NULL,
    shipping_limit_date DATETIME NULL,
    price               DECIMAL(10,2),
    freight_value       DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_items_order
        FOREIGN KEY (order_id)   REFERENCES orders (order_id),
    CONSTRAINT fk_items_product
        FOREIGN KEY (product_id) REFERENCES products (product_id),
    CONSTRAINT fk_items_seller
        FOREIGN KEY (seller_id)  REFERENCES sellers (seller_id)
);

-- -----------------------------------------------------
-- 7. order_payments
-- An order can be paid with several payments (payment_sequential).
-- -----------------------------------------------------
CREATE TABLE order_payments (
    order_id             VARCHAR(32) NOT NULL,
    payment_sequential   INT         NOT NULL,
    payment_type         VARCHAR(20),
    payment_installments INT,
    payment_value        DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

-- -----------------------------------------------------
-- 8. order_reviews
-- review_id is NOT unique in the raw data (duplicates exist),
-- so we add our own auto-increment key. Duplicates are handled
-- later in the cleaning step.
-- -----------------------------------------------------
CREATE TABLE order_reviews (
    review_pk               INT AUTO_INCREMENT PRIMARY KEY,
    review_id               VARCHAR(32),
    order_id                VARCHAR(32) NOT NULL,
    review_score            TINYINT,
    review_comment_title    VARCHAR(255),
    review_comment_message  TEXT,
    review_creation_date    DATETIME NULL,
    review_answer_timestamp DATETIME NULL,
    INDEX idx_reviews_order (order_id),
    INDEX idx_reviews_review (review_id),
    CONSTRAINT fk_reviews_order
        FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

-- -----------------------------------------------------
-- 9. geolocation (~1 million rows, import last; optional at first)
-- Many rows per zip code prefix, so no primary key from the data.
-- -----------------------------------------------------
CREATE TABLE geolocation (
    geolocation_pk              INT AUTO_INCREMENT PRIMARY KEY,
    geolocation_zip_code_prefix INT,
    geolocation_lat             DECIMAL(18,15),
    geolocation_lng             DECIMAL(18,15),
    geolocation_city            VARCHAR(100),
    geolocation_state           CHAR(2),
    INDEX idx_geo_zip (geolocation_zip_code_prefix)
);
