---
hide:
  - navigation
  - toc
---

# eBay Auction Platform

<div class="grid cards" markdown>

-   :material-gavel: **Real-Time Bidding**

    Robust bidding engine with highest-bid tracking and history.

-   :material-shield-check: **Enterprise Security**

    Role-based access control (RBAC), BCrypt hashing, and session management.

-   :material-view-dashboard: **Full Administration**

    Comprehensive dashboard for managing users, products, and categories.

-   :material-server: **Modern Java Stack**

    Built on Java 21 and Jakarta EE 10 standards with Tomcat 10.1+.

</div>

## Architecture in Action

The platform follows a clean, layered architecture separating **Controllers**, **Data Access**, and **Security**.

=== "1. Secure Filters"

    **`AuthFilter.java`** — Centralized security enforcement.

    ```java
    @WebFilter("/*")
    public class AuthFilter implements Filter {
        @Override
        public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {
            HttpServletRequest req = (HttpServletRequest) request;
            HttpSession session = req.getSession(false);
            
            boolean loggedIn = (session != null && session.getAttribute("auth.userId") != null);
            String path = req.getRequestURI();

            // Role-based Authorization
            if (path.startsWith("/admin/")) {
                String role = (String) session.getAttribute("auth.role");
                if (!"ADMIN".equals(role)) {
                    ((HttpServletResponse) response).sendError(403, "Access Denied");
                    return;
                }
            }
            
            chain.doFilter(request, response);
        }
    }
    ```

=== "2. Clean Controllers"

    **`LoginServlet.java`** — Handling business logic and routing.

    ```java
    @WebServlet("/login")
    public class LoginServlet extends HttpServlet {
        @Override
        protected void doPost(HttpServletRequest req, HttpServletResponse resp) {
            String username = req.getParameter("username");
            var user = userDao.findByUsername(username);

            // Secure Password Verification
            if (user == null || !PasswordUtil.verify(password, user.passwordHash())) {
                req.setAttribute("error", "Invalid credentials.");
                return;
            }

            // Session Creation
            HttpSession session = req.getSession(true);
            session.setAttribute("auth.userId", user.userId());
            session.setAttribute("auth.role", user.role());
            
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }
    ```

=== "3. Robust Data Access"

    **`BidDao.java`** — Safe database interactions with JDBC.

    ```java
    public void placeBid(Long productId, Long bidderId, BigDecimal amount) {
        final String sql = """
            INSERT INTO bids (product_id, bidder_user_id, amount)
            VALUES (?, ?, ?)
        """;

        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setLong(1, productId);
            ps.setLong(2, bidderId);
            ps.setBigDecimal(3, amount);
            ps.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("DB error in BidDao.placeBid", e);
        }
    }
    ```

## Quick Start

Get up and running in minutes.

```bash
# 1. Clone & Setup DB
git clone https://github.com/nettenz/ebay.git
mysql -u root -p < db/schema.sql

# 2. Build & Deploy
mvn clean package
cp target/ebay-1.0-SNAPSHOT.war $CATALINA_HOME/webapps/
```

[View Deployment Guide](deployment.md){ .md-button .md-button--primary }
[View Source Code](https://github.com/nettenz/ebay){ .md-button }
