# Authentication & Authorization

The eBay Auction Platform uses session-based authentication with BCrypt password hashing and role-based access control.

## Authentication Flow

### User Registration

```java
POST /register
Content-Type: application/x-www-form-urlencoded

username=john&password=secret123&email=john@example.com
```

**Process:**
1. Validate input (username uniqueness, password strength)
2. Hash password with BCrypt (12 rounds)
3. Insert user into database with default USER role
4. Create HTTP session
5. Redirect to user dashboard

### User Login

```java
POST /login
Content-Type: application/x-www-form-urlencoded

username=john&password=secret123
```

**Process:**
1. Query database for user by username
2. Verify password using `BCrypt.checkpw()`
3. On success:
    - Store user object in HTTP session
    - Redirect to appropriate dashboard (USER or ADMIN)
4. On failure:
    - Display error message
    - Remain on login page

### Session Management

**Session Attributes:**
```java
session.setAttribute("user", userObject);
```

**Session Validation:**
- `AuthFilter` intercepts all protected routes
- Checks for `user` attribute in session
- Redirects to login if not authenticated

### Logout

```java
GET /logout
```

**Process:**
1. Invalidate HTTP session
2. Clear all session attributes
3. Redirect to login page

## Authorization (Role-Based Access Control)

### User Roles

| Role    | Description                          | Access Level                |
|---------|--------------------------------------|-----------------------------|
| `USER`  | Standard registered user             | Create products, place bids |
| `ADMIN` | Administrator with elevated privileges | Manage users, products, departments |

### Role Enforcement

The `AuthFilter` enforces role-based access:

```java
// Check if admin route
if (uri.startsWith("/admin/")) {
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equals("ADMIN")) {
        response.sendRedirect("/login");
        return;
    }
}
```

### Protected Routes

**User Routes** (Require authentication):
- `/products/create` - Create new auction listing
- `/products/my-listings` - View own products
- `/bids/place` - Place a bid

**Admin Routes** (Require ADMIN role):
- `/admin/dashboard` - Admin statistics
- `/admin/users` - User management
- `/admin/products` - Product management
- `/admin/departments` - Category management

## Password Security

### BCrypt Hashing

**Configuration:**
- Algorithm: BCrypt
- Cost factor: 12 (2^12 iterations)
- Automatic salt generation

**Implementation:**
```java
import org.mindrot.jbcrypt.BCrypt;

// Hash password during registration
String hashedPassword = BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));

// Verify password during login
boolean isValid = BCrypt.checkpw(plainPassword, hashedPassword);
```

**Benefits:**
- Rainbow table resistant (salted)
- Computationally expensive for attackers
- Adaptive (cost factor can be increased)

### Password Requirements

!!! info "Current Implementation"
    Basic validation is implemented. Strengthen for production.

**Minimum Requirements:**
- Length: 6+ characters (should be increased to 12+)
- No specific complexity rules yet

**Planned:**
- Minimum 12 characters
- Mix of uppercase, lowercase, numbers, symbols
- Check against common password lists
- Password strength meter on UI

## Session Configuration

**Default Settings:**
- Timeout: 30 minutes of inactivity
- Secure flag: Not enforced (requires HTTPS)
- HttpOnly flag: Enabled (XSS protection)

**Recommended for Production:**
```xml
<!-- web.xml -->
<session-config>
    <session-timeout>30</session-timeout>
    <cookie-config>
        <http-only>true</http-only>
        <secure>true</secure>
        <same-site>Strict</same-site>
    </cookie-config>
</session-config>
```

## Security Considerations

### Current Protections

✅ **Password Hashing** - BCrypt with salt  
✅ **Session-based Auth** - Server-side session storage  
✅ **Role-based Access** - Filter-level enforcement  
✅ **HttpOnly Cookies** - JavaScript cannot access session cookie  

### Planned Improvements

🔄 **CSRF Protection**
- Token generation and validation
- Per-request or per-session tokens

🔄 **Rate Limiting**
- Prevent brute force attacks on `/login`
- Limit registration attempts

🔄 **Account Lockout**
- Lock after N failed login attempts
- Temporary lockout period

🔄 **Multi-factor Authentication (MFA)**
- TOTP-based 2FA
- SMS or email verification

🔄 **Audit Logging**
- Log all authentication events
- Track failed login attempts
- Monitor admin actions

## API Reference

### AuthFilter

**URL Patterns:**
- `/products/create/*`
- `/admin/*`
- `/bids/*`

**Behavior:**
1. Check session for user
2. Validate role for admin routes
3. Allow or deny access
4. Redirect to login on failure

### LoginServlet

| Endpoint | Method | Parameters            | Response              |
|----------|--------|------------------------|------------------------|
| `/login` | GET    | -                      | Login page (JSP)       |
| `/login` | POST   | username, password     | Redirect or error      |

### RegisterServlet

| Endpoint    | Method | Parameters                    | Response              |
|-------------|--------|-------------------------------|-----------------------|
| `/register` | GET    | -                             | Registration page     |
| `/register` | POST   | username, password, email     | Redirect or error     |

### LogoutServlet

| Endpoint  | Method | Parameters | Response           |
|-----------|--------|------------|--------------------|
| `/logout` | GET    | -          | Redirect to login  |

## Code Examples

### Check Authentication in Servlet

```java
@WebServlet("/protected-resource")
public class ProtectedServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("/login");
            return;
        }
        
        // Proceed with authorized logic
    }
}
```

### Check Admin Role

```java
if (!"ADMIN".equals(user.getRole())) {
    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
    return;
}
```

## Best Practices

1. **Always use HTTPS** in production to protect credentials in transit
2. **Never log passwords** - not even in debug mode
3. **Expire sessions** after reasonable inactivity period
4. **Use secure cookies** with HttpOnly and Secure flags
5. **Implement CSRF protection** for all state-changing operations
6. **Add rate limiting** on authentication endpoints
7. **Monitor failed login attempts** for security incidents

## Related Documentation

- [Security Guide](../security.md) - Comprehensive security overview
- [Database Schema](../database/schema.md) - User table structure
- [API Reference](../api/servlets.md) - Servlet endpoints
