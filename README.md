# eBay Auction Platform

A Java-based auction web application built with Jakarta EE. Features a full-stack marketplace with authentication, product listings, bidding engine, and admin management.

## Tech Stack
*   **Java 21**, **Jakarta EE 10** (Servlet / JSP)
*   **Maven 3.8+**, **MySQL 8.x**, **Apache Tomcat 10.1+**

## Quick Start

### 1. Database Setup
```bash
mysql -u root -p < db/schema.sql
```
*Creates `ebay_db` with default admin: `admin` / `admin123`*

### 2. Build & Run
```bash
mvn clean package
cp target/ebay-1.0-SNAPSHOT.war $CATALINA_HOME/webapps/
$CATALINA_HOME/bin/catalina.sh run
```
Access at: `http://localhost:8080/ebay-1.0-SNAPSHOT/`

## Project Status

### ✅ Functional
*   **Auth**: Session management, BCrypt, Role-based access (USER/ADMIN).
*   **Marketplace**: Product CRUD, image uploads, categorization.
*   **Bidding**: Real-time bidding engine, history tracking.
*   **Admin**: Dashboard for managing users, products, departments.

### 🚧 Roadmap
*   Auction lifecycle (auto-close, end-time validation).
*   Concurrent bid safety & proxy bidding.
*   CSRF tokens & API rate limiting.

## Configuration
Use environment variables in production:
*   `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`

## License
MIT