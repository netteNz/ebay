# eBay Auction Platform

Welcome to the documentation for the eBay Auction Platform - a Java-based auction web application built with Jakarta EE.

## Overview

This is a full-stack marketplace prototype demonstrating modern web development with:

- **Authentication & Authorization** - Session-based auth with BCrypt hashing and role-based access
- **Product Management** - Create, browse, and categorize auction listings
- **Bidding Engine** - Real-time bidding with highest bid tracking and history
- **Admin Dashboard** - Comprehensive management of users, products, and departments

## Tech Stack

- **Java:** 21
- **Framework:** Jakarta Servlet / JSP (EE 6.0)
- **Build:** Maven 3.8+
- **Database:** MySQL 8.x
- **Server:** Apache Tomcat 10.1+

## Quick Links

- [Getting Started](getting-started.md) - Set up and run the application
- [Architecture](architecture.md) - System design and structure
- [Database Setup](database/setup.md) - MySQL configuration
- [Deployment](deployment.md) - Production deployment guide

## Project Status

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

## Author

**Emanuel**  
Systems and Architectural Replica · Started December, 2025
