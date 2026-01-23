# Filters Reference

Documentation for servlet filters that handle cross-cutting concerns like authentication and authorization.

## Overview

Filters intercept HTTP requests before they reach servlets, allowing for centralized handling of:
- Authentication
- Authorization (role-based access)
- Logging
- CORS headers
- Request/response modification

## AuthFilter

**Location:** `src/main/java/com/nettenz/ebay/filter/AuthFilter.java`

### Purpose

Enforces authentication and role-based authorization on protected routes.

### URL Patterns

Configured in `web.xml` or via `@WebFilter` annotation:

```xml
<filter>
    <filter-name>AuthFilter</filter-name>
    <filter-class>com.nettenz.ebay.filter.AuthFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>AuthFilter</filter-name>
    <url-pattern>/products/create/*</url-pattern>
    <url-pattern>/bids/*</url-pattern>
    <url-pattern>/admin/*</url-pattern>
</filter-mapping>
```

Or with annotation:
```java
@WebFilter(
    urlPatterns = {
        "/products/create/*",
        "/bids/*",
        "/admin/*"
    }
)
```

### Logic Flow

```
1. Request arrives
2. Check HTTP session for user
3. If no user → redirect to /login
4. If admin route:
   a. Check user role == ADMIN
   b. If not ADMIN → 403 Forbidden
5. Allow request to proceed to servlet
```

### Implementation

```java
@WebFilter(urlPatterns = {"/products/create/*", "/bids/*", "/admin/*"})
public class AuthFilter implements Filter {
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        String uri = httpRequest.getRequestURI();
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        // Check authentication
        if (user == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }
        
        // Check admin authorization
        if (uri.contains("/admin/") && !"ADMIN".equals(user.getRole())) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }
        
        // Allow request to proceed
        chain.doFilter(request, response);
    }
}
```

### Protected Routes

**User Routes** (Require authentication):
- `/products/create/*` - Create product listings
- `/bids/*` - Place bids
- `/profile/*` - User profile

**Admin Routes** (Require ADMIN role):
- `/admin/*` - All admin functionality

### Bypassed Routes

Public routes not protected by filter:
- `/` - Homepage
- `/login` - Login page
- `/register` - Registration page
- `/products` - Product listing (GET only)
- `/products/{id}` - Product details
- `/images` - Image serving
- `/static/*` - CSS, JS, images

### Session Validation

**Session Attributes:**
```java
User user = (User) session.getAttribute("user");
```

**User Object Fields:**
- `userId` (int)
- `username` (String)
- `email` (String)
- `role` (String) - "USER" or "ADMIN"

### Error Handling

**Not Authenticated:**
- HTTP 302 redirect to `/login`
- Sets return URL for post-login redirect

**Not Authorized:**
- HTTP 403 Forbidden
- Custom error page displayed

---

## CORSFilter (Planned)

### Purpose

Handle Cross-Origin Resource Sharing for API requests.

### Headers

```java
response.setHeader("Access-Control-Allow-Origin", "*");
response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
```

### Implementation

```java
@WebFilter("/*")
public class CORSFilter implements Filter {
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        httpResponse.setHeader("Access-Control-Allow-Origin", "*");
        httpResponse.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        httpResponse.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        
        chain.doFilter(request, response);
    }
}
```

---

## LoggingFilter (Planned)

### Purpose

Log all HTTP requests for debugging and auditing.

### Logged Information

- Request method (GET, POST, etc.)
- Request URI
- Query parameters
- User ID (if authenticated)
- Response status code
- Response time

### Implementation

```java
@WebFilter("/*")
public class LoggingFilter implements Filter {
    
    private static final Logger logger = LoggerFactory.getLogger(LoggingFilter.class);
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        long startTime = System.currentTimeMillis();
        
        try {
            chain.doFilter(request, response);
        } finally {
            long duration = System.currentTimeMillis() - startTime;
            HttpSession session = httpRequest.getSession(false);
            User user = (session != null) ? (User) session.getAttribute("user") : null;
            
            logger.info("Method: {}, URI: {}, User: {}, Duration: {}ms",
                httpRequest.getMethod(),
                httpRequest.getRequestURI(),
                user != null ? user.getUsername() : "anonymous",
                duration
            );
        }
    }
}
```

---

## CSRFFilter (Planned)

### Purpose

Prevent Cross-Site Request Forgery attacks.

### Token Generation

```java
// Generate CSRF token
String token = UUID.randomUUID().toString();
session.setAttribute("csrf_token", token);
```

### Token Validation

```java
String sessionToken = (String) session.getAttribute("csrf_token");
String requestToken = request.getParameter("csrf_token");

if (!sessionToken.equals(requestToken)) {
    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
    return;
}
```

### Usage in Forms

```html
<form action="/products/create" method="POST">
    <input type="hidden" name="csrf_token" value="${sessionScope.csrf_token}">
    <!-- other fields -->
</form>
```

---

## RateLimitFilter (Planned)

### Purpose

Prevent abuse by rate-limiting requests per IP/user.

### Configuration

```java
private static final int MAX_REQUESTS_PER_MINUTE = 60;
private static final Map<String, Queue<Long>> requestTimestamps = new ConcurrentHashMap<>();
```

### Implementation

```java
@WebFilter("/login")
public class RateLimitFilter implements Filter {
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String ipAddress = httpRequest.getRemoteAddr();
        
        Queue<Long> timestamps = requestTimestamps.computeIfAbsent(
            ipAddress, 
            k -> new ConcurrentLinkedQueue<>()
        );
        
        long now = System.currentTimeMillis();
        
        // Remove old timestamps (older than 1 minute)
        timestamps.removeIf(time -> now - time > 60000);
        
        if (timestamps.size() >= MAX_REQUESTS_PER_MINUTE) {
            HttpServletResponse httpResponse = (HttpServletResponse) response;
            httpResponse.sendError(429, "Too many requests. Try again later.");
            return;
        }
        
        timestamps.add(now);
        chain.doFilter(request, response);
    }
}
```

---

## Filter Ordering

Filters execute in the order they're declared in `web.xml` or by class name if using annotations.

### Recommended Order

1. **CORSFilter** - Set CORS headers first
2. **LoggingFilter** - Log all requests
3. **RateLimitFilter** - Check rate limits early
4. **CSRFFilter** - Validate CSRF tokens
5. **AuthFilter** - Check authentication/authorization
6. **Servlet** - Execute business logic

### Configuration

```xml
<!-- web.xml -->
<filter-mapping>
    <filter-name>CORSFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>

<filter-mapping>
    <filter-name>LoggingFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>

<filter-mapping>
    <filter-name>AuthFilter</filter-name>
    <url-pattern>/admin/*</url-pattern>
    <url-pattern>/products/create/*</url-pattern>
</filter-mapping>
```

---

## Testing Filters

### Unit Testing

```java
@Test
public void testAuthFilter_NoSession_RedirectsToLogin() {
    MockHttpServletRequest request = new MockHttpServletRequest();
    MockHttpServletResponse response = new MockHttpServletResponse();
    MockFilterChain chain = new MockFilterChain();
    
    authFilter.doFilter(request, response, chain);
    
    assertEquals(302, response.getStatus());
    assertTrue(response.getRedirectedUrl().contains("/login"));
}
```

### Integration Testing

```java
@Test
public void testProtectedRoute_WithoutAuth_Returns401() {
    given()
        .when()
        .get("/products/create")
        .then()
        .statusCode(302)  // Redirect to login
        .header("Location", containsString("/login"));
}
```

---

## Best Practices

1. **Keep filters lightweight** - Heavy logic belongs in servlets
2. **Order matters** - Authentication before authorization
3. **Handle exceptions** - Don't let filters crash
4. **Log filter activity** - Especially auth failures
5. **Use chain.doFilter()** - Always call to pass request along
6. **Test thoroughly** - Filters affect all requests

---

## Related Documentation

- [Servlets](servlets.md) - Servlet endpoint reference
- [Authentication](../features/authentication.md) - Auth system details
- [Security](../security.md) - Security best practices

