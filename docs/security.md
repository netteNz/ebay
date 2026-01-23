# Security Guide

Comprehensive security documentation for the eBay Auction Platform.

## Current Security Measures

### ✅ Implemented

#### Password Security
- **BCrypt hashing** with 12 rounds
- Automatic salt generation per user
- Never store plaintext passwords
- Password hashes never exposed in responses

```java
// Hashing during registration
String hashedPassword = BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));

// Verification during login
boolean isValid = BCrypt.checkpw(plainPassword, storedHash);
```

#### SQL Injection Prevention
- **PreparedStatements** for all database queries
- No string concatenation in SQL
- Parameterized queries throughout DAO layer

```java
// GOOD - Safe from SQL injection
String sql = "SELECT * FROM users WHERE username = ?";
PreparedStatement ps = conn.prepareStatement(sql);
ps.setString(1, username);

// BAD - Vulnerable to SQL injection
String sql = "SELECT * FROM users WHERE username = '" + username + "'";
Statement st = conn.createStatement(sql);  // NEVER DO THIS
```

#### Session Management
- HTTP sessions for authentication state
- Session invalidation on logout
- HttpOnly cookies (JavaScript cannot access)

#### Role-Based Access Control (RBAC)
- USER and ADMIN roles
- Filter-level authorization checks
- Protected admin routes

#### Database Security
- Foreign key constraints
- Cascade delete where appropriate
- RESTRICT delete for critical relationships

---

## Planned Improvements

### 🔄 High Priority

#### 1. CSRF Protection

**Problem:** State-changing operations vulnerable to cross-site request forgery.

**Solution:** CSRF tokens for all forms

```java
// Generate token
String csrfToken = UUID.randomUUID().toString();
session.setAttribute("csrf_token", csrfToken);
```

```html
<!-- Include in forms -->
<form action="/products/create" method="POST">
    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
    <!-- other fields -->
</form>
```

```java
// Validate token in servlet
String sessionToken = (String) session.getAttribute("csrf_token");
String requestToken = request.getParameter("csrf_token");

if (!sessionToken.equals(requestToken)) {
    response.sendError(403, "Invalid CSRF token");
    return;
}
```

#### 2. HTTPS Enforcement

**Problem:** Credentials transmitted in plaintext over HTTP.

**Solution:** Enforce HTTPS, redirect HTTP to HTTPS

```xml
<!-- web.xml -->
<security-constraint>
    <web-resource-collection>
        <web-resource-name>Entire Application</web-resource-name>
        <url-pattern>/*</url-pattern>
    </web-resource-collection>
    <user-data-constraint>
        <transport-guarantee>CONFIDENTIAL</transport-guarantee>
    </user-data-constraint>
</security-constraint>
```

#### 3. Input Sanitization (XSS Prevention)

**Problem:** User input not sanitized, vulnerable to XSS attacks.

**Solution:** Sanitize all user-generated content

```java
// Add OWASP Java HTML Sanitizer dependency
import org.owasp.html.PolicyFactory;
import org.owasp.html.Sanitizers;

PolicyFactory policy = Sanitizers.FORMATTING.and(Sanitizers.LINKS);
String safeHtml = policy.sanitize(userInput);
```

**In JSP:**
```jsp
<!-- Use JSTL's <c:out> to escape HTML -->
<c:out value="${product.description}" escapeXml="true"/>

<!-- Or fn:escapeXml -->
${fn:escapeXml(product.description)}
```

#### 4. Rate Limiting

**Problem:** No protection against brute force attacks.

**Solution:** Implement rate limiting on authentication endpoints

```java
@WebFilter("/login")
public class RateLimitFilter implements Filter {
    private static final Map<String, List<Long>> requestLog = new ConcurrentHashMap<>();
    private static final int MAX_REQUESTS = 5;
    private static final long TIME_WINDOW = 60000; // 1 minute
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        String ip = request.getRemoteAddr();
        long now = System.currentTimeMillis();
        
        List<Long> timestamps = requestLog.computeIfAbsent(ip, k -> new ArrayList<>());
        timestamps.removeIf(time -> now - time > TIME_WINDOW);
        
        if (timestamps.size() >= MAX_REQUESTS) {
            ((HttpServletResponse) response).sendError(429, "Too many requests");
            return;
        }
        
        timestamps.add(now);
        chain.doFilter(request, response);
    }
}
```

---

## Vulnerability Checklist

### Authentication & Authorization

- [x] Passwords hashed with BCrypt
- [x] Session-based authentication
- [x] Role-based access control
- [ ] Multi-factor authentication (MFA)
- [ ] Account lockout after failed attempts
- [ ] Password complexity requirements
- [ ] Password reset functionality (secure)
- [ ] Session timeout after inactivity
- [x] HttpOnly cookies
- [ ] Secure flag on cookies (requires HTTPS)
- [ ] SameSite cookie attribute

### Input Validation

- [x] SQL injection prevention (PreparedStatements)
- [ ] XSS prevention (output encoding)
- [ ] Command injection prevention
- [ ] Path traversal prevention
- [ ] File upload validation
- [ ] Email format validation
- [ ] URL validation
- [ ] Integer overflow checks

### Data Protection

- [x] Password hashing (never plaintext)
- [ ] Sensitive data encryption at rest
- [ ] HTTPS for data in transit
- [ ] Secure database credentials
- [ ] No secrets in source code
- [ ] Environment variable configuration
- [ ] Secure session storage

### API Security

- [ ] CSRF protection
- [ ] CORS policy
- [ ] API rate limiting
- [ ] Request size limits
- [ ] Response header security

### Error Handling

- [ ] Generic error messages (no stack traces)
- [ ] Custom error pages
- [ ] Error logging (not to user)
- [ ] No sensitive data in logs

### File Security

- [ ] File upload restrictions (type, size)
- [ ] Malware scanning on uploads
- [ ] Store uploads outside webroot
- [ ] Secure file serving

---

## Common Vulnerabilities & Fixes

### 1. SQL Injection

**Vulnerable Code:**
```java
String sql = "SELECT * FROM users WHERE username = '" + username + "'";
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(sql);
```

**Attack:**
```
username = "admin' OR '1'='1"
```

**Fixed Code:**
```java
String sql = "SELECT * FROM users WHERE username = ?";
PreparedStatement ps = conn.prepareStatement(sql);
ps.setString(1, username);
ResultSet rs = ps.executeQuery();
```

### 2. Cross-Site Scripting (XSS)

**Vulnerable Code:**
```jsp
<div>${product.description}</div>
```

**Attack:**
```
description = "<script>alert('XSS')</script>"
```

**Fixed Code:**
```jsp
<div><c:out value="${product.description}" escapeXml="true"/></div>
```

Or sanitize before storage:
```java
String safeDescription = Sanitizers.FORMATTING.sanitize(description);
```

### 3. Cross-Site Request Forgery (CSRF)

**Vulnerable Code:**
```html
<form action="/admin/users/delete" method="POST">
    <input type="hidden" name="userId" value="123">
    <button>Delete</button>
</form>
```

**Attack:**
Attacker hosts page with:
```html
<form id="evil" action="https://yoursite.com/admin/users/delete" method="POST">
    <input type="hidden" name="userId" value="1">
</form>
<script>document.getElementById('evil').submit();</script>
```

**Fixed Code:**
```html
<form action="/admin/users/delete" method="POST">
    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
    <input type="hidden" name="userId" value="123">
    <button>Delete</button>
</form>
```

### 4. Insecure Direct Object Reference (IDOR)

**Vulnerable Code:**
```java
// /products/edit?id=123
int productId = Integer.parseInt(request.getParameter("id"));
Product product = productDao.findById(productId);
// No authorization check!
```

**Attack:**
User changes `id=123` to `id=456` to edit someone else's product.

**Fixed Code:**
```java
int productId = Integer.parseInt(request.getParameter("id"));
Product product = productDao.findById(productId);

// Check ownership
User currentUser = (User) session.getAttribute("user");
if (product.getSellerId() != currentUser.getId() && !"ADMIN".equals(currentUser.getRole())) {
    response.sendError(403, "Access denied");
    return;
}
```

### 5. Session Fixation

**Vulnerable Code:**
```java
// Use existing session
HttpSession session = request.getSession();
session.setAttribute("user", user);
```

**Fixed Code:**
```java
// Invalidate old session and create new one
HttpSession oldSession = request.getSession(false);
if (oldSession != null) {
    oldSession.invalidate();
}
HttpSession newSession = request.getSession(true);
newSession.setAttribute("user", user);
```

---

## Security Headers

Add security headers to all responses:

```java
@WebFilter("/*")
public class SecurityHeadersFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // Prevent clickjacking
        httpResponse.setHeader("X-Frame-Options", "DENY");
        
        // XSS protection
        httpResponse.setHeader("X-XSS-Protection", "1; mode=block");
        
        // Prevent MIME sniffing
        httpResponse.setHeader("X-Content-Type-Options", "nosniff");
        
        // Content Security Policy
        httpResponse.setHeader("Content-Security-Policy", 
            "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';");
        
        // HSTS (HTTPS only)
        httpResponse.setHeader("Strict-Transport-Security", 
            "max-age=31536000; includeSubDomains");
        
        // Referrer policy
        httpResponse.setHeader("Referrer-Policy", "no-referrer-when-downgrade");
        
        chain.doFilter(request, response);
    }
}
```

---

## Audit Logging

Log security-relevant events:

```java
public class AuditLogger {
    private static final Logger logger = LoggerFactory.getLogger(AuditLogger.class);
    
    public static void logLogin(String username, boolean success, String ip) {
        logger.info("LOGIN: user={}, success={}, ip={}", username, success, ip);
    }
    
    public static void logLogout(String username) {
        logger.info("LOGOUT: user={}", username);
    }
    
    public static void logAdminAction(String admin, String action, String target) {
        logger.warn("ADMIN_ACTION: admin={}, action={}, target={}", admin, action, target);
    }
    
    public static void logFailedAuth(String username, String reason, String ip) {
        logger.warn("AUTH_FAILED: user={}, reason={}, ip={}", username, reason, ip);
    }
}
```

---

## Security Testing

### Manual Testing

**Test for SQL Injection:**
```
username: admin' OR '1'='1
username: admin'; DROP TABLE users; --
```

**Test for XSS:**
```
description: <script>alert('XSS')</script>
description: <img src=x onerror=alert('XSS')>
```

**Test for CSRF:**
1. Login to application
2. Create malicious page with form
3. Submit and see if it succeeds

**Test for IDOR:**
1. Login as user1
2. Access /products/edit?id=X (product owned by user2)
3. Should be denied

### Automated Testing

**OWASP ZAP (Zed Attack Proxy):**
```bash
docker run -t owasp/zap2docker-stable zap-baseline.py \
    -t http://localhost:8080/ebay-1.0-SNAPSHOT/
```

**SQLMap (SQL Injection Testing):**
```bash
sqlmap -u "http://localhost:8080/ebay/login" \
    --data="username=test&password=test" \
    --level=5 --risk=3
```

---

## Secure Configuration

### Production Checklist

- [ ] Change default admin password
- [ ] Enable HTTPS with valid certificate
- [ ] Configure secure cookies (Secure, HttpOnly, SameSite)
- [ ] Set appropriate session timeout
- [ ] Disable directory listing
- [ ] Remove default Tomcat apps (examples, docs)
- [ ] Configure firewall (only 80/443 public)
- [ ] Use environment variables for secrets
- [ ] Enable audit logging
- [ ] Implement backup strategy
- [ ] Set up monitoring and alerts
- [ ] Keep dependencies updated
- [ ] Run security scans regularly

---

## Dependencies

Keep dependencies up to date to avoid known vulnerabilities:

```bash
# Check for vulnerable dependencies
mvn dependency-check:check

# Update to latest versions
mvn versions:display-dependency-updates
```

**Critical Dependencies:**
- Jakarta Servlet API - Keep updated
- MySQL Connector/J - Check for CVEs
- BCrypt library - Verify no known issues

---

## Incident Response

### If Breach Occurs

1. **Isolate:** Take application offline immediately
2. **Investigate:** Review logs, identify scope
3. **Notify:** Inform affected users
4. **Fix:** Patch vulnerability
5. **Reset:** Force password resets
6. **Restore:** From clean backup if needed
7. **Monitor:** Watch for further attempts
8. **Document:** Post-mortem analysis

### Contact

**Security Issues:** Report to security@nettenz.com (if configured)

---

## Related Documentation

- [Authentication](features/authentication.md) - Auth system details
- [Filters](api/filters.md) - Security filter implementation
- [Deployment](deployment.md) - Secure deployment practices

