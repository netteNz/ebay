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

-- SEED DATA
-- Default Admin: admin / password
INSERT INTO users (username, email, password_hash, role)
VALUES ('admin', 'admin@nettenz.com', '$2a$12$R9h/cIPz0gi.URQHeNV5ad1ED9WnJqnNozIdITxlfX.qPGImeQz6i', 'ADMIN')
ON DUPLICATE KEY UPDATE username=username;

-- Sample Departments
INSERT INTO departments (name) VALUES ('Electronics') ON DUPLICATE KEY UPDATE name=name;
INSERT INTO departments (name) VALUES ('Collectibles') ON DUPLICATE KEY UPDATE name=name;
INSERT INTO departments (name) VALUES ('Fashion') ON DUPLICATE KEY UPDATE name=name;
INSERT INTO departments (name) VALUES ('Home & Garden') ON DUPLICATE KEY UPDATE name=name;

-- Sample Products (seller_user_id=1 is admin)
INSERT INTO products (seller_user_id, department_id, name, description, image_url, starting_bid) VALUES
(1, 1, 'Vintage Polaroid Camera', 'Classic instant camera from the 1970s in excellent condition.', 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=400', 45.00),
(1, 1, 'Mechanical Keyboard', 'Cherry MX Blue switches, RGB backlit, compact 65% layout.', 'https://images.unsplash.com/photo-1595225476474-87563907a212?w=400', 89.00),
(1, 2, 'Rare Vinyl Record Collection', 'Set of 20 classic rock albums from the 60s and 70s.', 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=400', 150.00),
(1, 2, 'Antique Pocket Watch', 'Gold-plated pocket watch circa 1920, fully functional.', 'https://images.unsplash.com/photo-1509048191080-d2984bad6ae5?w=400', 275.00),
(1, 3, 'Leather Messenger Bag', 'Handcrafted genuine leather bag, perfect for laptops.', 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400', 65.00),
(1, 4, 'Ceramic Plant Pots Set', 'Set of 3 minimalist ceramic pots in matte white.', 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400', 35.00)
ON DUPLICATE KEY UPDATE name=name;

