package com.nettenz.ebay.servlet.admin;

import com.nettenz.ebay.dao.DepartmentDao;
import com.nettenz.ebay.dao.DepartmentDao.DepartmentRecord;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/departments")
public class AdminDepartmentsServlet extends HttpServlet {

    private final DepartmentDao departmentDao = new DepartmentDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<DepartmentRecord> list = departmentDao.findAll();
        req.setAttribute("departments", list);
        req.getRequestDispatcher("/WEB-INF/jsp/admin/departments.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = req.getParameter("name");
        if (name != null && !name.isBlank()) {
            departmentDao.create(name);
        }
        resp.sendRedirect(req.getContextPath() + "/admin/departments");
    }
}
