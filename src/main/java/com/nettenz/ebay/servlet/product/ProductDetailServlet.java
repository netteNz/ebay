package com.nettenz.ebay.servlet.product;

import com.nettenz.ebay.dao.BidDao;
import com.nettenz.ebay.dao.ProductDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/products/*")
public class ProductDetailServlet extends HttpServlet {

    private final ProductDao productDao = new ProductDao();
    private final BidDao bidDao = new BidDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        
        // Skip if no path or if it's the "new" route (handled by CreateProductServlet)
        if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("/new")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Parse product ID from path: /products/123
        String idStr = pathInfo.substring(1); // Remove leading slash
        
        // Handle /products/123/bid route - redirect to GET (bid is POST only)
        if (idStr.contains("/")) {
            idStr = idStr.split("/")[0];
        }

        Long productId;
        try {
            productId = Long.parseLong(idStr);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        ProductDao.ProductDto product = productDao.findById(productId);
        if (product == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        List<BidDao.BidDto> bidHistory = bidDao.getBidHistory(productId);
        
        req.setAttribute("product", product);
        req.setAttribute("bidHistory", bidHistory);
        req.getRequestDispatcher("/WEB-INF/jsp/product/detail.jsp").forward(req, resp);
    }
}
