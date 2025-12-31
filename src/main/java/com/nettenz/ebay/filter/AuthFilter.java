package com.nettenz.ebay.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Set;

@WebFilter("/*")
public class AuthFilter implements Filter {

    // Paths that don't require authentication
    private static final Set<String> PUBLIC_PATHS = Set.of(
            "/login",
            "/register",
            "/logout",
            "/products"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String path = req.getRequestURI().substring(req.getContextPath().length());

        // 1. Allow root, index.jsp, and explicit public paths
        if (path.equals("/") || path.equals("/index.jsp") || PUBLIC_PATHS.contains(path)) {
            chain.doFilter(request, response);
            return;
        }

        // 2. Check Session
        HttpSession session = req.getSession(false);
        boolean loggedIn = (session != null && session.getAttribute("auth.userId") != null);

        if (!loggedIn) {
            // Redirect to login with the current path as returnTo
            resp.sendRedirect(req.getContextPath() + "/login?returnTo=" + path);
            return;
        }

        // 3. Role-based Authorization for Admin paths
        if (path.startsWith("/admin/")) {
            String role = (String) session.getAttribute("auth.role");
            if (!"ADMIN".equals(role)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Admin role required.");
                return;
            }
        }

        // 4. Authenticated access to everything else (like /products/*)
        chain.doFilter(request, response);
    }

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void destroy() {}
}
