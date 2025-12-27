-- db/schema.sql
-- Base schema for eBay-style auction app (rubric-ready)

CREATE DATABASE IF NOT EXISTS ebay
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE ebay;

-- USERS
-- password_hash stores bcrypt/argon2 hash string (never plaintext)
-- role distinguishes USER vs ADMIN (admin can manage users/products/departments)
CREATE TABLE IF NOT EXISTS users (
                                     user_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
                                     username       VARCHAR(50)  NOT NULL UNIQUE,
    email          VARCHAR(255) NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    role           ENUM('USER','ADMIN') NOT NULL DEFAULT 'USER',
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );

-- DEPARTMENTS (admin-managed)
CREATE TABLE IF NOT EXISTS departments (
                                           department_id  BIGINT AUTO_INCREMENT PRIMARY KEY,
                                           name           VARCHAR(100) NOT NULL UNIQUE,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );

-- PRODUCTS (seller lists an item)
CREATE TABLE IF NOT EXISTS products (
                                        product_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
                                        department_id  BIGINT NULL,
                                        seller_user_id BIGINT NOT NULL,
                                        name           VARCHAR(200) NOT NULL,
    description    TEXT NULL,
    image_url      VARCHAR(500) NULL,
    starting_bid   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_products_seller
    FOREIGN KEY (seller_user_id) REFERENCES users(user_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_products_dept
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
    ON DELETE SET NULL ON UPDATE CASCADE
    );

-- BIDS (bidding history)
CREATE TABLE IF NOT EXISTS bids (
                                    bid_id         BIGINT AUTO_INCREMENT PRIMARY KEY,
                                    product_id     BIGINT NOT NULL,
                                    bidder_user_id BIGINT NOT NULL,
                                    amount         DECIMAL(10,2) NOT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_bids_product
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_bids_bidder
    FOREIGN KEY (bidder_user_id) REFERENCES users(user_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,

    INDEX idx_bids_product_amount (product_id, amount),
    INDEX idx_bids_product_created (product_id, created_at)
    );
