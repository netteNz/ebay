package com.nettenz.ebay.servlet.auth;

import com.nettenz.ebay.dao.UserDao;
import com.nettenz.ebay.util.PasswordUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            req.getRequestDispatcher("/WEB-INF/jsp/auth/login.jsp").forward(req, resp);
        } catch (Exception e) {
            resp.sendError(500, "Unable to load login page");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String returnTo = req.getParameter("returnTo");

        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Username and password are required.");
            try {
                req.getRequestDispatcher("/WEB-INF/jsp/auth/login.jsp").forward(req, resp);
            } catch (Exception ignored) {}
            return;
        }

        var user = userDao.findByUsername(username);
        if (user == null || !PasswordUtil.verify(password, user.passwordHash())) {
            req.setAttribute("error", "Invalid credentials.");
            try {
                req.getRequestDispatcher("/WEB-INF/jsp/auth/login.jsp").forward(req, resp);
            } catch (Exception ignored) {}
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("auth.userId", user.userId());
        session.setAttribute("auth.username", user.username());
        session.setAttribute("auth.role", user.role()); // "USER" or "ADMIN"

        // Safe-ish redirect: allow only relative paths
        if (returnTo != null && !returnTo.isBlank() && returnTo.startsWith("/")) {
            resp.sendRedirect(req.getContextPath() + returnTo);
        } else {
            resp.sendRedirect(req.getContextPath() + "/");
        }
    }
}
