# Admin Dashboard

The admin dashboard provides comprehensive management tools for users, products, departments, and system statistics.

## Access Control

**Role Required:** `ADMIN`

**Protected Routes:**
- `/admin/dashboard`
- `/admin/users`
- `/admin/products`
- `/admin/departments`

**Enforcement:**
```java
if (!"ADMIN".equals(user.getRole())) {
    response.sendError(HttpServletResponse.SC_FORBIDDEN);
    return;
}
```

## Dashboard Overview

### Statistics Panel

**Endpoint:** `GET /admin/dashboard`

**Key Metrics:**
- Total users (with growth trend)
- Total products (active vs closed)
- Total bids placed
- Revenue (completed auctions)
- Active auctions
- User registrations (today, this week, this month)

**Example Display:**
```
┌─────────────────────────────────────────────┐
│          Admin Dashboard                    │
├─────────────────────────────────────────────┤
│  Total Users:        1,247 (+12 this week) │
│  Total Products:     3,456 (892 active)    │
│  Total Bids:         12,789                │
│  Completed Sales:    $45,678.90            │
│  Active Auctions:    892                   │
└─────────────────────────────────────────────┘
```

### Charts & Graphs (Planned)

- User registration trends (line chart)
- Product categories breakdown (pie chart)
- Daily bid activity (bar chart)
- Revenue over time (area chart)

## User Management

### User List

**Endpoint:** `GET /admin/users`

**Features:**
- Paginated list of all users
- Search by username or email
- Filter by role (USER, ADMIN)
- Sort by registration date, last login

**Displayed Info:**
| ID  | Username   | Email              | Role  | Registered  | Status   | Actions |
|-----|------------|--------------------|-------|-------------|----------|---------|
| 1   | admin      | admin@ebay.com     | ADMIN | 2025-12-01  | Active   | Edit    |
| 2   | john_doe   | john@example.com   | USER  | 2025-12-15  | Active   | Edit, Ban |
| 3   | jane_smith | jane@example.com   | USER  | 2025-12-20  | Banned   | Unban   |

### User Actions

**Edit User:**
- Update email, password, role
- View user activity (products, bids)

**Ban/Suspend User:**
```java
POST /admin/users/{id}/ban
Reason: Violating terms of service
Duration: Permanent | 7 days | 30 days
```

**Delete User:**
- Soft delete (mark as inactive)
- Hard delete (cascade: products, bids)
- Requires confirmation

**Promote to Admin:**
```java
POST /admin/users/{id}/promote
user.setRole("ADMIN");
userDao.update(user);
```

## Product Management

### Product List

**Endpoint:** `GET /admin/products`

**Features:**
- View all products (any user)
- Filter by status (active, closed, flagged)
- Search by name or description
- Sort by price, date, bid count

**Actions:**
- Edit product details
- Delete product
- Feature on homepage
- Close auction early
- Flag for review

### Product Moderation

**Flagged Products:**
- User reports inappropriate content
- Auto-flagged by keyword filters
- Admin reviews and takes action

**Actions:**
- Approve (remove flag)
- Edit content
- Remove listing
- Warn/suspend seller

## Department Management

### Department List

**Endpoint:** `GET /admin/departments`

**CRUD Operations:**

**Create Department:**
```html
<form action="/admin/departments/create" method="POST">
    <input type="text" name="name" placeholder="Department Name" required>
    <textarea name="description" placeholder="Description"></textarea>
    <button type="submit">Create</button>
</form>
```

**Edit Department:**
- Update name or description
- View product count in department

**Delete Department:**
- Only if no products assigned
- Or reassign products to another department

**List View:**
| ID | Name          | Description                | Product Count | Actions      |
|----|---------------|----------------------------|---------------|--------------|
| 1  | Electronics   | Gadgets and devices        | 456           | Edit, Delete |
| 2  | Fashion       | Clothing and accessories   | 234           | Edit, Delete |
| 3  | Home & Garden | Home improvement items     | 123           | Edit, Delete |

## Audit Logging (Planned)

### Activity Tracking

**Events to Log:**
- User bans/unbans
- Product deletions
- Department changes
- Role promotions
- Configuration changes

**Log Entry:**
```java
{
    "timestamp": "2026-01-23T19:00:00Z",
    "admin_user_id": 1,
    "action": "USER_BANNED",
    "target_user_id": 42,
    "reason": "Spam posting",
    "ip_address": "192.168.1.100"
}
```

### Audit Log Viewer

**Endpoint:** `GET /admin/audit-log`

**Filters:**
- By admin user
- By action type
- By date range
- By target user/product

## Reports & Analytics (Planned)

### Revenue Reports

- Daily/weekly/monthly revenue
- Revenue by department
- Top-selling products
- Commission calculations

### User Analytics

- User growth trends
- Active vs inactive users
- User engagement metrics
- Geographic distribution

### Product Analytics

- Most viewed products
- Conversion rates (views → bids → sales)
- Average auction duration
- Price trends by category

## System Configuration (Planned)

### Settings Panel

**Endpoint:** `GET /admin/settings`

**Configurable Options:**
- Site name and description
- Default auction duration
- Minimum bid increments
- Image upload limits
- Email templates
- Maintenance mode

**Example:**
```java
{
    "site_name": "eBay Auction Platform",
    "default_auction_days": 7,
    "min_bid_increment": 1.00,
    "max_image_size_mb": 5,
    "maintenance_mode": false
}
```

## Database Queries

### User Statistics

```sql
-- Total users
SELECT COUNT(*) FROM users;

-- New users this week
SELECT COUNT(*) FROM users 
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- Users by role
SELECT role, COUNT(*) 
FROM users 
GROUP BY role;
```

### Product Statistics

```sql
-- Total products
SELECT COUNT(*) FROM products;

-- Active auctions
SELECT COUNT(*) FROM products 
WHERE status = 'ACTIVE';

-- Products by department
SELECT d.name, COUNT(p.id) as product_count
FROM departments d
LEFT JOIN products p ON d.id = p.department_id
GROUP BY d.id;
```

### Bid Statistics

```sql
-- Total bids
SELECT COUNT(*) FROM bids;

-- Bids today
SELECT COUNT(*) FROM bids 
WHERE created_at >= CURDATE();

-- Average bids per product
SELECT AVG(bid_count) FROM (
    SELECT product_id, COUNT(*) as bid_count
    FROM bids
    GROUP BY product_id
) as bid_counts;
```

## API Reference

### AdminDashboardServlet

| Endpoint               | Method | Description                |
|------------------------|--------|----------------------------|
| `/admin/dashboard`     | GET    | Main dashboard stats       |
| `/admin/users`         | GET    | List all users             |
| `/admin/users/{id}`    | GET    | View user details          |
| `/admin/users/{id}`    | POST   | Update user                |
| `/admin/users/{id}/ban`| POST   | Ban user                   |
| `/admin/products`      | GET    | List all products          |
| `/admin/products/{id}` | DELETE | Delete product             |
| `/admin/departments`   | GET    | List departments           |
| `/admin/departments`   | POST   | Create department          |
| `/admin/audit-log`     | GET    | View audit log             |

## Security Considerations

### Admin Access Control

**Best Practices:**
1. **Limit admin accounts** - Only trusted personnel
2. **Audit all actions** - Track what admins do
3. **Require re-authentication** - For destructive actions
4. **IP whitelisting** - Restrict admin panel access
5. **Two-factor authentication** - Extra security layer

### Dangerous Actions

**Require Confirmation:**
- Deleting users
- Deleting products with active bids
- Banning users
- Clearing database tables

**Example:**
```javascript
function deleteUser(userId) {
    if (!confirm("Are you sure? This action cannot be undone.")) {
        return false;
    }
    
    const reason = prompt("Enter reason for deletion:");
    if (!reason) {
        return false;
    }
    
    // Proceed with deletion
    fetch(`/admin/users/${userId}`, {
        method: 'DELETE',
        body: JSON.stringify({ reason })
    });
}
```

## Performance Considerations

### Caching Statistics

**Problem:** Dashboard queries can be expensive

**Solution:** Cache statistics
```java
@Cacheable(value = "dashboardStats", ttl = 300) // 5 minutes
public DashboardStats getStatistics() {
    return statsDao.fetchAllStats();
}
```

### Pagination

**Large Tables:**
```java
// Don't load all users at once
List<User> users = userDao.findAll(page, pageSize);
```

**SQL:**
```sql
SELECT * FROM users 
LIMIT ? OFFSET ?
```

## Code Examples

### Dashboard Statistics

```java
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        // Check admin role
        User user = (User) request.getSession().getAttribute("user");
        if (!"ADMIN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        // Fetch statistics
        int totalUsers = statsDao.getTotalUsers();
        int totalProducts = statsDao.getTotalProducts();
        int totalBids = statsDao.getTotalBids();
        
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("totalBids", totalBids);
        
        request.getRequestDispatcher("/WEB-INF/jsp/admin/dashboard.jsp")
               .forward(request, response);
    }
}
```

### Ban User

```java
@WebServlet("/admin/users/*/ban")
public class BanUserServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        int userId = Integer.parseInt(request.getParameter("userId"));
        String reason = request.getParameter("reason");
        
        User targetUser = userDao.findById(userId);
        targetUser.setStatus("BANNED");
        targetUser.setBanReason(reason);
        userDao.update(targetUser);
        
        // Log action
        auditService.logBan(currentAdmin, targetUser, reason);
        
        response.sendRedirect("/admin/users");
    }
}
```

## Best Practices

1. **Log everything** - Audit trail for accountability
2. **Confirm destructive actions** - Prevent accidents
3. **Cache statistics** - Improve dashboard performance
4. **Paginate large lists** - Don't overwhelm the browser
5. **Restrict admin IPs** - Additional security layer
6. **Regular backups** - Before bulk operations
7. **Test in staging** - Before production changes

## Related Documentation

- [Authentication](authentication.md) - Role-based access control
- [Database Schema](../database/schema.md) - Tables and relationships
- [Security Guide](../security.md) - Admin security best practices
