# Project Handover & Status Checkpoint
**Date:** December 31, 2025
**Current Status:** Functional Prototype (Auth, Product Creation, Admin Dashboard)
**Next Phase:** Bidding Engine Implementation

## 📂 Project Architecture
*   **Type:** Java Maven Web App (Jakarta EE 6.0, JSP, MySQL)
*   **Database Schema:** `users`, `products`, `departments` (seeded), `bids` (created but unused).
*   **Image Storage:** Local filesystem (`/uploads`) served via `ImageServlet`.

## 🛠️ Key Components Implemented

### 1. Security (`com.nettenz.ebay.filter.AuthFilter`)
*   Intercepts all requests.
*   **Public:** `/`, `/login`, `/register`, `/products`, `/images/*`.
*   **Admin:** `/admin/*` (Requires `role='ADMIN'` in session).
*   **Protected:** `/products/new` (Requires valid session).

### 2. Product Creation (`CreateProductServlet`)
*   **Path:** `/products/new`
*   **Features:**
    *   Multipart file upload support (images saved to `uploads/`).
    *   Fallback to external URL if provided.
    *   Dynamic Department dropdown (populated from DB).

### 3. Admin Dashboard
*   **Path:** `/admin/dashboard`
*   **Features:**
    *   Live stats via `StatsDao`.
    *   Sub-pages for Users (`/admin/users`), Products (`/admin/products`), and Departments (`/admin/departments`).

## 📋 Technical Handover: Next Steps

The next session should focus immediately on the **Bidding Logic**.

### Priority 1: Implement Bidding
1.  **Create `BidDao`**:
    *   Method `placeBid(userId, productId, amount)`.
    *   **Validation:** Must check if `amount > current_max_bid` (or `starting_bid` if no bids exist).
2.  **Create `BidServlet`**:
    *   Handle `POST /bid`.
    *   Redirect back to product page with success/error message.
3.  **Update UI (`list.jsp`)**:
    *   Replace the "Place Bid" placeholder button with a small input form.
    *   Show the **Current Highest Bid** prominently.

### Priority 2: Product Details
*   Create a specific page (`/product?id=X`) to show full history and description before bidding.