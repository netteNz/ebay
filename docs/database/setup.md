# Database Setup

This guide walks you through setting up MySQL for the eBay Auction Platform.

## Prerequisites

- MySQL 8.x installed
- MySQL command-line client or GUI tool (MySQL Workbench)
- Root or administrative access

## Installation

### macOS (Homebrew)

```bash
brew install mysql
brew services start mysql
```

### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
```

### Windows

1. Download MySQL Installer from [mysql.com](https://dev.mysql.com/downloads/installer/)
2. Run installer and select "Developer Default"
3. Follow installation wizard
4. Start MySQL service from Services panel

## Secure Installation

```bash
sudo mysql_secure_installation
```

Follow prompts to:
- Set root password
- Remove anonymous users
- Disallow root login remotely
- Remove test database

## Create Database

### Option 1: Using Schema Script

```bash
mysql -u root -p < db/schema.sql
```

This will:
- Create `ebay` database with UTF8MB4
- Create all tables (users, products, departments, bids)
- Insert seed data (admin user, sample departments, sample products)

### Option 2: Manual Creation

```sql
-- Connect to MySQL
mysql -u root -p

-- Create database
CREATE DATABASE ebay
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- Use database
USE ebay;

-- Run schema.sql contents
SOURCE /path/to/db/schema.sql;
```

## Verify Installation

```sql
-- Show databases
SHOW DATABASES;

-- Use ebay database
USE ebay;

-- List tables
SHOW TABLES;

-- Check users table
SELECT * FROM users;

-- Check departments
SELECT * FROM departments;

-- Check products
SELECT * FROM products;
```

**Expected Output:**
```
+-------+
| Tables_in_ebay |
+-------+
| bids           |
| departments    |
| products       |
| users          |
+-------+
```

## Default Credentials

### Admin User

Created automatically by schema script:

- **Username:** `admin`
- **Password:** `admin123`
- **Email:** `admin@nettenz.com`
- **Role:** `ADMIN`

!!! danger "Change Default Password"
    Immediately change the admin password in production:
    ```sql
    UPDATE users 
    SET password_hash = '$2a$12$NEW_HASH_HERE'
    WHERE username = 'admin';
    ```

## Application Configuration

### Database Connection

Update your JDBC configuration (typically in a config file or hardcoded):

```java
// DatabaseConnection.java
private static final String URL = "jdbc:mysql://localhost:3306/ebay?useSSL=false&serverTimezone=UTC";
private static final String USER = "root";  // Change in production
private static final String PASSWORD = "yourpassword";
```

### Environment Variables (Recommended)

```bash
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=ebay
export DB_USER=app_user
export DB_PASSWORD=secure_password
```

```java
String url = String.format(
    "jdbc:mysql://%s:%s/%s",
    System.getenv("DB_HOST"),
    System.getenv("DB_PORT"),
    System.getenv("DB_NAME")
);
String user = System.getenv("DB_USER");
String password = System.getenv("DB_PASSWORD");
```

## Create Application User (Production)

Don't use root in production. Create dedicated user:

```sql
-- Create user
CREATE USER 'ebay_app'@'localhost' IDENTIFIED BY 'strong_password_here';

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ebay.* TO 'ebay_app'@'localhost';

-- Apply changes
FLUSH PRIVILEGES;

-- Test connection
mysql -u ebay_app -p ebay
```

## Connection Pooling (Optional but Recommended)

Add HikariCP dependency to `pom.xml`:

```xml
<dependency>
    <groupId>com.zaxxer</groupId>
    <artifactId>HikariCP</artifactId>
    <version>5.0.1</version>
</dependency>
```

Configure connection pool:

```java
HikariConfig config = new HikariConfig();
config.setJdbcUrl("jdbc:mysql://localhost:3306/ebay");
config.setUsername("ebay_app");
config.setPassword("password");
config.setMaximumPoolSize(10);
config.setMinimumIdle(2);
config.setConnectionTimeout(30000);

HikariDataSource dataSource = new HikariDataSource(config);
```

## Troubleshooting

### Cannot Connect to MySQL

**Issue:** Connection refused

**Solution:**
```bash
# Check MySQL is running
sudo systemctl status mysql  # Linux
brew services list            # macOS

# Start MySQL if stopped
sudo systemctl start mysql    # Linux
brew services start mysql     # macOS
```

### Authentication Failed

**Issue:** Access denied for user

**Solution:**
- Verify username and password
- Check user exists: `SELECT User, Host FROM mysql.user;`
- Reset password: `ALTER USER 'user'@'localhost' IDENTIFIED BY 'new_password';`

### Database Not Found

**Issue:** Unknown database 'ebay'

**Solution:**
```sql
-- Create database
CREATE DATABASE ebay;

-- Or run schema script
SOURCE db/schema.sql;
```

### Charset/Collation Issues

**Issue:** Emoji or special characters not displaying

**Solution:**
```sql
-- Check database charset
SHOW CREATE DATABASE ebay;

-- Should show: CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci

-- Fix if needed
ALTER DATABASE ebay CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
```

## Backup & Restore

### Backup

```bash
# Full database backup
mysqldump -u root -p ebay > backup.sql

# With timestamp
mysqldump -u root -p ebay > backup_$(date +%Y%m%d_%H%M%S).sql

# Compress backup
mysqldump -u root -p ebay | gzip > backup.sql.gz
```

### Restore

```bash
# From SQL file
mysql -u root -p ebay < backup.sql

# From compressed file
gunzip < backup.sql.gz | mysql -u root -p ebay
```

## Performance Tuning

### MySQL Configuration

Edit `/etc/mysql/my.cnf` or `/etc/my.cnf`:

```ini
[mysqld]
# Connection settings
max_connections = 200
connect_timeout = 10

# Buffer sizes
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M

# Query cache (MySQL 5.7 and older)
query_cache_type = 1
query_cache_size = 64M

# Character set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
```

Restart MySQL after changes:
```bash
sudo systemctl restart mysql
```

### Monitor Performance

```sql
-- Show processlist
SHOW PROCESSLIST;

-- Show slow queries
SHOW VARIABLES LIKE 'slow_query%';

-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;
```

## Docker Setup (Alternative)

Use Docker Compose for development:

```yaml
# docker-compose.yml (already exists in project root)
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: ebay
      MYSQL_USER: ebay_app
      MYSQL_PASSWORD: app_password
    ports:
      - "3306:3306"
    volumes:
      - ./db/schema.sql:/docker-entrypoint-initdb.d/schema.sql
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

Start with:
```bash
docker-compose up -d
```

## Next Steps

- [Schema Documentation](schema.md) - Understand table structure
- [Getting Started](../getting-started.md) - Build and run the application
- [Security Guide](../security.md) - Production security setup

