# Servlet API Reference

Complete reference for all servlet endpoints in the eBay Auction Platform.

## Base URL

```
http://localhost:8080/ebay-1.0-SNAPSHOT/
```

## Authentication Endpoints

### LoginServlet

**Path:** `/login`

#### GET /login
Display login form.

**Response:** Login page (JSP)

#### POST /login
Authenticate user.

**Parameters:**
- `username` (String, required) - User's username
- `password` (String, required) - User's password

**Response:**
- Success: Redirect to `/` or `/admin/dashboard`
- Failure: Display error message on login page

**Example:**
```html
<form action="/login" method="POST">
    <input type="text" name="username" required>
    <input type="password" name="password" required>
    <button type="submit">Login</button>
</form>
```

---

### RegisterServlet

**Path:** `/register`

#### GET /register
Display registration form.

**Response:** Registration page (JSP)

#### POST /register
Create new user account.

**Parameters:**
- `username` (String, required) - Desired username
- `password` (String, required) - Password (min 6 chars)
- `email` (String, optional) - Email address

**Response:**
- Success: Redirect to `/login`
- Failure: Display validation errors

**Validation:**
- Username must be unique
- Password minimum 6 characters
- Email format validation (if provided)

---

### LogoutServlet

**Path:** `/logout`

#### GET /logout
End user session.

**Response:** Redirect to `/login`

---

## Product Endpoints

### ProductServlet

**Path:** `/products`

#### GET /products
List all products.

**Parameters:**
- `departmentId` (int, optional) - Filter by department
- `search` (String, optional) - Search by name/description

**Response:** Product listing page (JSP)

**Authorization:** None (public)

---

### CreateProductServlet

**Path:** `/products/create`

#### GET /products/create
Display product creation form.

**Response:** Create product page (JSP)

**Authorization:** USER or ADMIN role required

#### POST /products/create
Create new product listing.

**Content-Type:** `multipart/form-data`

**Parameters:**
- `name` (String, required) - Product name
- `description` (String, required) - Product description
- `departmentId` (int, required) - Category ID
- `price` (decimal, required) - Starting bid
- `image` (File, optional) - Image upload
- `imageUrl` (String, optional) - External image URL

**Response:**
- Success: Redirect to `/products`
- Failure: Display validation errors

**Authorization:** USER or ADMIN role required

---

### ProductDetailServlet

**Path:** `/products/{id}`

#### GET /products/{id}
View product details.

**Path Parameters:**
- `id` (int) - Product ID

**Response:** Product detail page (JSP) with bid history

**Authorization:** None (public)

---

### ImageServlet

**Path:** `/images`

#### GET /images
Serve product image.

**Parameters:**
- `id` (int, required) - Product ID

**Response:** Image file (JPEG/PNG/GIF)

**Authorization:** None (public)

---

## Bidding Endpoints

### BidServlet

**Path:** `/bids/place`

#### POST /bids/place
Place a bid on a product.

**Parameters:**
- `productId` (int, required) - Product to bid on
- `amount` (decimal, required) - Bid amount

**Response:**
- Success: JSON `{"success": true, "message": "Bid placed"}`
- Failure: JSON `{"success": false, "error": "Bid too low"}`

**Validation:**
- User must be authenticated
- Amount must exceed current highest bid
- Cannot bid on own products

**Authorization:** USER or ADMIN role required

---

### BidHistoryServlet

**Path:** `/products/{id}/bids`

#### GET /products/{id}/bids
View bid history for a product.

**Path Parameters:**
- `id` (int) - Product ID

**Response:** Bid history page (JSP)

**Authorization:** None (public)

---

## Admin Endpoints

All admin endpoints require ADMIN role.

### AdminDashboardServlet

**Path:** `/admin/dashboard`

#### GET /admin/dashboard
View admin statistics.

**Response:** Dashboard page (JSP) with stats

**Statistics:**
- Total users
- Total products
- Total bids
- Active auctions

**Authorization:** ADMIN role required

---

### AdminUsersServlet

**Path:** `/admin/users`

#### GET /admin/users
List all users.

**Parameters:**
- `page` (int, optional) - Page number (default: 1)
- `search` (String, optional) - Search by username/email

**Response:** User management page (JSP)

**Authorization:** ADMIN role required

#### POST /admin/users/{id}
Update user details.

**Path Parameters:**
- `id` (int) - User ID

**Parameters:**
- `email` (String) - New email
- `role` (String) - USER or ADMIN
- `status` (String) - ACTIVE, BANNED, SUSPENDED

**Response:** Redirect to `/admin/users`

**Authorization:** ADMIN role required

---

### AdminProductsServlet

**Path:** `/admin/products`

#### GET /admin/products
List all products (admin view).

**Response:** Product management page (JSP)

**Authorization:** ADMIN role required

#### DELETE /admin/products/{id}
Delete a product.

**Path Parameters:**
- `id` (int) - Product ID

**Response:** Redirect to `/admin/products`

**Authorization:** ADMIN role required

---

### AdminDepartmentsServlet

**Path:** `/admin/departments`

#### GET /admin/departments
List all departments.

**Response:** Department management page (JSP)

**Authorization:** ADMIN role required

#### POST /admin/departments
Create new department.

**Parameters:**
- `name` (String, required) - Department name
- `description` (String, optional) - Description

**Response:** Redirect to `/admin/departments`

**Authorization:** ADMIN role required

#### PUT /admin/departments/{id}
Update department.

**Path Parameters:**
- `id` (int) - Department ID

**Parameters:**
- `name` (String) - New name
- `description` (String) - New description

**Response:** Redirect to `/admin/departments`

**Authorization:** ADMIN role required

#### DELETE /admin/departments/{id}
Delete department.

**Path Parameters:**
- `id` (int) - Department ID

**Response:** Redirect to `/admin/departments`

**Authorization:** ADMIN role required

---

## Error Responses

### HTTP Status Codes

- `200 OK` - Success
- `302 Found` - Redirect
- `400 Bad Request` - Validation error
- `401 Unauthorized` - Not authenticated
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

### Error Page

Custom error pages in `WEB-INF/jsp/error/`:
- `404.jsp` - Not found
- `403.jsp` - Access denied
- `500.jsp` - Server error

---

## Request Examples

### cURL Examples

**Login:**
```bash
curl -X POST http://localhost:8080/ebay-1.0-SNAPSHOT/login \
  -d "username=admin&password=admin123" \
  -c cookies.txt
```

**Create Product:**
```bash
curl -X POST http://localhost:8080/ebay-1.0-SNAPSHOT/products/create \
  -b cookies.txt \
  -F "name=Vintage Camera" \
  -F "description=Classic Polaroid" \
  -F "departmentId=1" \
  -F "price=45.00" \
  -F "image=@camera.jpg"
```

**Place Bid:**
```bash
curl -X POST http://localhost:8080/ebay-1.0-SNAPSHOT/bids/place \
  -b cookies.txt \
  -d "productId=1&amount=50.00"
```

---

## Related Documentation

- [Filters](filters.md) - Authentication and authorization filters
- [Features](../features/) - Detailed feature documentation
- [Database Schema](../database/schema.md) - Data structures

