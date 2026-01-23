# Database Schema

This document describes the database structure for the eBay Auction Platform.

## Overview

**Database:** MySQL 8.x  
**Character Set:** UTF8MB4  
**Collation:** utf8mb4_unicode_ci  
**Engine:** InnoDB (default)

## Entity Relationship Diagram

```
┌──────────────┐         ┌──────────────┐
│    users     │         │ departments  │
│──────────────│         │──────────────│
│ user_id (PK) │         │ dept_id (PK) │
│ username     │         │ name         │
│ email        │         │ created_at   │
│ password_hash│         └──────────────┘
│ role         │                │
│ created_at   │                │
└──────┬───────┘                │
       │                        │
       │ seller_user_id         │ department_id
       │                        │
       ├────────────────────────┤
       │                        │
       ▼                        ▼
┌──────────────────────────────────┐
│          products                │
│──────────────────────────────────│
│ product_id (PK)                  │
│ department_id (FK)               │
│ seller_user_id (FK)              │
│ name                             │
│ description                      │
│ image_url                        │
│ starting_bid                     │
│ created_at                       │
└────────┬─────────────────────────┘
         │
         │ product_id
         │
         ▼
    ┌──────────────┐
    │     bids     │
    │──────────────│
    │ bid_id (PK)  │
    │ product_id(FK)│
    │ bidder_id(FK)│
    │ amount       │
    │ created_at   │
    └──────────────┘
         │
         │ bidder_user_id
         │
         ▼
    (back to users)
```

## Tables

### users

Stores user accounts with authentication and role information.

```sql
CREATE TABLE users (
    user_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    username       VARCHAR(50)  NOT NULL UNIQUE,
    email          VARCHAR(255) NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    role           ENUM('USER','ADMIN') NOT NULL DEFAULT 'USER',
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

**Columns:**
- `user_id` - Unique identifier
- `username` - Login name (unique, indexed)
- `email` - Email address (unique, nullable)
- `password_hash` - BCrypt hashed password (never plaintext)
- `role` - Either `USER` or `ADMIN`
- `created_at` - Registration timestamp

**Indexes:**
- PRIMARY KEY: `user_id`
- UNIQUE: `username`, `email`

**Sample Data:**
```sql
INSERT INTO users (username, email, password_hash, role) VALUES
('admin', 'admin@nettenz.com', '$2a$12$R9h/cIPz...', 'ADMIN'),
('john_doe', 'john@example.com', '$2a$12$xyz...', 'USER');
```

### departments

Product categories managed by admins.

```sql
CREATE TABLE departments (
    department_id  BIGINT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(100) NOT NULL UNIQUE,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

**Columns:**
- `department_id` - Unique identifier
- `name` - Category name (unique)
- `created_at` - Creation timestamp

**Indexes:**
- PRIMARY KEY: `department_id`
- UNIQUE: `name`

**Sample Data:**
```sql
INSERT INTO departments (name) VALUES
('Electronics'),
('Fashion'),
('Home & Garden'),
('Collectibles');
```

### products

Auction listings created by users.

```sql
CREATE TABLE products (
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
```

**Columns:**
- `product_id` - Unique identifier
- `department_id` - Category (nullable, FK to departments)
- `seller_user_id` - Product owner (FK to users)
- `name` - Product title
- `description` - Full description (TEXT)
- `image_url` - Path to image or external URL
- `starting_bid` - Initial price
- `created_at` - Listing timestamp

**Foreign Keys:**
- `seller_user_id` → `users(user_id)` - RESTRICT delete
- `department_id` → `departments(department_id)` - SET NULL on delete

**Indexes:**
- PRIMARY KEY: `product_id`
- FOREIGN KEY indexes auto-created

**Sample Data:**
```sql
INSERT INTO products (seller_user_id, department_id, name, description, image_url, starting_bid) VALUES
(1, 1, 'iPhone 15 Pro', '256GB, Space Black, like new', '/uploads/iphone.jpg', 800.00),
(1, 2, 'Leather Jacket', 'Vintage genuine leather', '/uploads/jacket.jpg', 120.00);
```

### bids

Bidding history for all products.

```sql
CREATE TABLE bids (
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
    
    INDEX idx_bids_product_amount (product_id, amount DESC),
    INDEX idx_bids_product_created (product_id, created_at DESC)
);
```

**Columns:**
- `bid_id` - Unique identifier
- `product_id` - Product being bid on (FK)
- `bidder_user_id` - User placing bid (FK)
- `amount` - Bid price
- `created_at` - Bid timestamp

**Foreign Keys:**
- `product_id` → `products(product_id)` - CASCADE delete
- `bidder_user_id` → `users(user_id)` - RESTRICT delete

**Indexes:**
- PRIMARY KEY: `bid_id`
- `idx_bids_product_amount` - Fast highest bid queries
- `idx_bids_product_created` - Chronological bid history

**Sample Data:**
```sql
INSERT INTO bids (product_id, bidder_user_id, amount) VALUES
(1, 2, 820.00),
(1, 3, 850.00),
(1, 2, 875.00);
```

## Relationships

### One-to-Many

**users → products**
- One user can create many products
- One product has one seller

**departments → products**
- One department contains many products
- One product belongs to one department (nullable)

**products → bids**
- One product can have many bids
- One bid belongs to one product

**users → bids**
- One user can place many bids
- One bid is placed by one user

## Queries

### Common Queries

**Get highest bid for a product:**
```sql
SELECT MAX(amount) as highest_bid, bidder_user_id
FROM bids
WHERE product_id = ?
GROUP BY bidder_user_id
ORDER BY highest_bid DESC
LIMIT 1;
```

**Get all products in a department:**
```sql
SELECT p.*, u.username as seller_name
FROM products p
JOIN users u ON p.seller_user_id = u.user_id
WHERE p.department_id = ?
ORDER BY p.created_at DESC;
```

**Get bid history for a product:**
```sql
SELECT b.*, u.username as bidder_name
FROM bids b
JOIN users u ON b.bidder_user_id = u.user_id
WHERE b.product_id = ?
ORDER BY b.created_at DESC;
```

**Get user's active products:**
```sql
SELECT p.*, COUNT(b.bid_id) as bid_count, MAX(b.amount) as highest_bid
FROM products p
LEFT JOIN bids b ON p.product_id = b.product_id
WHERE p.seller_user_id = ?
GROUP BY p.product_id
ORDER BY p.created_at DESC;
```

**Admin statistics:**
```sql
-- Total users
SELECT COUNT(*) FROM users;

-- Total products
SELECT COUNT(*) FROM products;

-- Total bids
SELECT COUNT(*) FROM bids;

-- Products by department
SELECT d.name, COUNT(p.product_id) as product_count
FROM departments d
LEFT JOIN products p ON d.department_id = p.department_id
GROUP BY d.department_id;
```

## Planned Schema Changes

### Additional Fields

**products table:**
```sql
ALTER TABLE products
ADD COLUMN status ENUM('DRAFT', 'ACTIVE', 'CLOSED') DEFAULT 'ACTIVE',
ADD COLUMN end_time TIMESTAMP NULL,
ADD COLUMN reserve_price DECIMAL(10,2) NULL,
ADD COLUMN buy_now_price DECIMAL(10,2) NULL,
ADD COLUMN view_count INT DEFAULT 0;
```

**users table:**
```sql
ALTER TABLE users
ADD COLUMN status ENUM('ACTIVE', 'BANNED', 'SUSPENDED') DEFAULT 'ACTIVE',
ADD COLUMN ban_reason TEXT NULL,
ADD COLUMN last_login TIMESTAMP NULL;
```

### New Tables

**audit_log** - Track admin actions:
```sql
CREATE TABLE audit_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    admin_user_id BIGINT NOT NULL,
    action VARCHAR(100) NOT NULL,
    target_table VARCHAR(50),
    target_id BIGINT,
    details TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_user_id) REFERENCES users(user_id)
);
```

**notifications** - User notifications:
```sql
CREATE TABLE notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

**proxy_bids** - Automatic bidding:
```sql
CREATE TABLE proxy_bids (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    max_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

## Performance Optimization

### Indexes

**Current:**
- All primary keys auto-indexed
- Foreign keys auto-indexed
- Unique constraints indexed
- Custom bid indexes for performance

**Recommended:**
```sql
-- Speed up product searches
CREATE INDEX idx_products_department_created 
ON products(department_id, created_at DESC);

-- Speed up user lookups
CREATE INDEX idx_users_email ON users(email);

-- Speed up bid queries
CREATE INDEX idx_bids_bidder ON bids(bidder_user_id, created_at DESC);
```

### Query Optimization

**Use EXPLAIN:**
```sql
EXPLAIN SELECT * FROM products WHERE department_id = 1;
```

**Avoid N+1 queries:**
```sql
-- BAD: N+1 queries
products = SELECT * FROM products;
for each product:
    bids = SELECT * FROM bids WHERE product_id = product.id;

-- GOOD: Single JOIN
SELECT p.*, COUNT(b.bid_id) as bid_count
FROM products p
LEFT JOIN bids b ON p.product_id = b.product_id
GROUP BY p.product_id;
```

## Backup & Recovery

### Backup Command

```bash
# Full database backup
mysqldump -u root -p ebay > backup_$(date +%Y%m%d).sql

# Tables only (no data)
mysqldump -u root -p --no-data ebay > schema.sql

# Specific table
mysqldump -u root -p ebay users > users_backup.sql
```

### Restore Command

```bash
mysql -u root -p ebay < backup_20260123.sql
```

### Automated Backups (Recommended)

```bash
# Cron job: Daily backup at 2 AM
0 2 * * * mysqldump -u backup_user -p'password' ebay | gzip > /backups/ebay_$(date +\%Y\%m\%d).sql.gz
```

## Security Considerations

### SQL Injection Prevention

**Always use PreparedStatements:**
```java
// GOOD
PreparedStatement ps = conn.prepareStatement(
    "SELECT * FROM users WHERE username = ?"
);
ps.setString(1, username);

// BAD - NEVER DO THIS
Statement st = conn.createStatement();
st.executeQuery("SELECT * FROM users WHERE username = '" + username + "'");
```

### Password Storage

- **Never** store plaintext passwords
- Use BCrypt with cost factor 12+
- Salt automatically generated per user

### Access Control

```sql
-- Create read-only user for reports
CREATE USER 'readonly'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON ebay.* TO 'readonly'@'localhost';

-- Create app user with limited permissions
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT, INSERT, UPDATE, DELETE ON ebay.* TO 'app_user'@'localhost';
FLUSH PRIVILEGES;
```

## Related Documentation

- [Database Setup](setup.md) - Installation guide
- [Architecture](../architecture.md) - DAO layer design
- [Security Guide](../security.md) - Best practices

