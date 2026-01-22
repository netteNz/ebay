# eBay Auction Platform

A Java-based auction web application built with Jakarta EE. This project demonstrates a full-stack marketplace prototype with authentication, product listings, and admin management.

## Tech Stack
- **Java:** 21
- **Framework:** Jakarta Servlet / JSP (EE 6.0)
- **Build:** Maven 3.8+
- **Database:** MySQL 8.x
- **Server:** Apache Tomcat 10.1+

## Status

### ✅ Fully Functional
- Authentication & session management (BCrypt hashing)
- User registration, login, logout
- Role-based authorization (USER / ADMIN)
- Product creation, browsing, categorization
- Admin dashboard (users, products, departments)
- Image uploads & external URL support
- **Bidding engine** - place bids, highest bid tracking, bid history

### 🔄 In Progress
- Auction lifecycle (end-time validation, auto-close)
- Concurrent bid safety (transaction isolation)
- Bid increment rules & reserve pricing

### 📋 Planned
- CSRF tokens, HTTPS, XSS sanitization
- Rate limiting on auth endpoints
- Proxy bidding system
- Audit logging for admin actions

## Project Structure
```
src/main/java/com/nettenz/ebay/
├── db/        # Database connection
├── dao/       # Data access layer
├── servlet/   # Auth, product, admin, image endpoints
├── filter/    # Auth & role-based access
└── util/      # Password hashing

src/main/webapp/
├── index.jsp
└── WEB-INF/jsp/ (auth, product, admin views)

db/schema.sql
uploads/        # Product images
```

## Quick Start

### Prerequisites
Java 21 · Maven · MySQL 8 · Tomcat 10.1+

### Setup
```bash
mysql -u root -p
SOURCE db/schema.sql

mvn clean package
cp target/ebay-1.0-SNAPSHOT.war $CATALINA_HOME/webapps/
```

Access: `http://localhost:8080/ebay-1.0-SNAPSHOT/`

## Core Features
- Session-based authentication with BCrypt hashing
- USER / ADMIN role separation via servlet filters
- Product creation, browsing, and categorization
- Image upload or external image URL support
- Admin dashboard for users, products, and departments

## Database
Core tables: `users`, `products`, `departments`, `bids`  
See `db/schema.sql` for full DDL.

## Security
**Implemented:** BCrypt hashing, PreparedStatements, role-based access  
**Planned:** CSRF tokens, HTTPS, XSS sanitization, rate limiting

## Notes
- Database credentials and upload paths are currently hardcoded
- Use environment variables in production

## Author
**Emanuel**  
Systems and Architectural Replica · Started December, 2025