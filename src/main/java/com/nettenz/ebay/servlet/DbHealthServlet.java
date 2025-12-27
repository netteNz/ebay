package com.nettenz.ebay.servlet;

import com.nettenz.ebay.db.Db;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/db-health")
public class DbHealthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        resp.setContentType("text/plain");

        try (var conn = Db.getConnection()) {
            resp.getWriter().println("DB OK");
        } catch (Exception e) {
            resp.setStatus(500);
            resp.getWriter().println("DB ERROR");
            e.printStackTrace(resp.getWriter());
        }
    }
}
