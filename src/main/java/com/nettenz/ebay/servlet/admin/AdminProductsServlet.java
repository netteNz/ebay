package com.nettenz.ebay.servlet.admin;

import com.nettenz.ebay.dao.ProductDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/products")
public class AdminProductsServlet extends HttpServlet {

    private final ProductDao productDao = new ProductDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<ProductDao.ProductDto> products = productDao.findAll();
        req.setAttribute("products", products);
        req.getRequestDispatcher("/WEB-INF/jsp/admin/products.jsp").forward(req, resp);
    }
}
