package com.nettenz.ebay.servlet.auth;

import com.nettenz.ebay.dao.UserDao;
import com.nettenz.ebay.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/jsp/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // 1. Basic Validation
        if (isEmpty(username) || isEmpty(password)) {
            fail(req, resp, "All fields are required.");
            return;
        }

        if (!password.equals(confirmPassword)) {
            fail(req, resp, "Passwords do not match.");
            return;
        }

        // 2. Business Validation (Duplicates)
        if (userDao.existsByUsername(username)) {
            fail(req, resp, "Username is already taken.");
            return;
        }

        // 3. Create User
        String hash = PasswordUtil.hash(password);
        userDao.create(username, hash, "USER");

        // 4. Redirect to Login
        resp.sendRedirect(req.getContextPath() + "/login?registered=true");
    }

    private boolean isEmpty(String s) {
        return s == null || s.isBlank();
    }

    private void fail(HttpServletRequest req, HttpServletResponse resp, String error) throws ServletException, IOException {
        req.setAttribute("error", error);
        req.getRequestDispatcher("/WEB-INF/jsp/auth/register.jsp").forward(req, resp);
    }
}
