# Architecture Overview

This document describes the high-level architecture and design decisions for the eBay Auction Platform.

## Architectural Style

* **Monolithic web application**
* **Layered architecture** (Servlet → DAO → Database)
* Server-side rendering using **JSP**

```
Browser
  ↓ HTTP
Servlets (Controllers)
  ↓
DAO Layer (JDBC)
  ↓
MySQL Database
```

## Layers

### 1. Presentation Layer (JSP)

* JSP views under `WEB-INF/jsp/`
* Responsible for rendering HTML
* No direct database access

### 2. Controller Layer (Servlets)

* Handles HTTP requests and responses
* Performs validation and authorization checks
* Delegates persistence to DAO classes

Examples:

* `LoginServlet`
* `CreateProductServlet`
* `AdminDashboardServlet`

### 3. Filter Layer

* Cross-cutting concerns
* Authentication and role-based authorization
* Protects admin and authenticated routes

Key component:

* `AuthFilter`

### 4. Data Access Layer (DAO)

* Encapsulates all SQL logic
* Uses JDBC with PreparedStatements
* Prevents SQL injection and isolates persistence

Examples:

* `UserDao`
* `ProductDao`
* `StatsDao`

### 5. Database Layer

* MySQL 8.x
* Relational schema with foreign keys
* Core tables: users, products, departments, bids

## Authentication Flow

1. User submits credentials
2. Password verified via BCrypt
3. User object stored in HTTP session
4. `AuthFilter` enforces access rules

## Image Handling

* Multipart uploads stored on disk (`uploads/`)
* Images served through `ImageServlet`
* Supports external image URLs as fallback

## Bidding Engine (Planned)

* `BidDao` for bid persistence and queries
* `BidServlet` for bid placement
* Transaction-safe highest-bid validation
* UI updates to show live bid state

## Security Considerations

* BCrypt password hashing (12 rounds)
* PreparedStatements for all queries
* Session-based authentication

### Planned Improvements

* CSRF tokens
* HTTPS enforcement
* Input sanitization (XSS)
* Rate limiting on auth endpoints
* Audit logging for admin actions

## Deployment

* Built as WAR via Maven
* Deployed to Apache Tomcat 10.1+
* Environment-specific config planned for production

## Future Evolution

* Auction closing scheduler
* Bid history & product detail pages
* Environment-based configuration
* Possible migration to REST + SPA frontend
