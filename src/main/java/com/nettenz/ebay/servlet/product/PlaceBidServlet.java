package com.nettenz.ebay.servlet.product;

import com.nettenz.ebay.dao.BidDao;
import com.nettenz.ebay.dao.ProductDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;

@WebServlet("/bid")
public class PlaceBidServlet extends HttpServlet {

    private final ProductDao productDao = new ProductDao();
    private final BidDao bidDao = new BidDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        
        // Must be logged in
        Long userId = (session != null) ? (Long) session.getAttribute("auth.userId") : null;
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Get parameters
        String productIdStr = req.getParameter("productId");
        String amountStr = req.getParameter("amount");

        if (productIdStr == null || amountStr == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            return;
        }

        Long productId;
        BigDecimal bidAmount;
        try {
            productId = Long.parseLong(productIdStr);
            bidAmount = new BigDecimal(amountStr);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid parameters");
            return;
        }

        // Get product
        ProductDao.ProductDto product = productDao.findById(productId);
        if (product == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
            return;
        }

        // Business Rule: Seller cannot bid on their own item
        if (product.sellerId().equals(userId)) {
            req.getSession().setAttribute("bidError", "You cannot bid on your own item");
            resp.sendRedirect(req.getContextPath() + "/products/" + productId);
            return;
        }

        // Business Rule: Bid must be greater than current price
        if (bidAmount.compareTo(product.currentPrice()) <= 0) {
            req.getSession().setAttribute("bidError", "Bid must be greater than $" + product.currentPrice());
            resp.sendRedirect(req.getContextPath() + "/products/" + productId);
            return;
        }

        // Place the bid
        bidDao.placeBid(productId, userId, bidAmount);
        
        req.getSession().setAttribute("bidSuccess", "Bid placed successfully for $" + bidAmount);
        resp.sendRedirect(req.getContextPath() + "/products/" + productId);
    }
}
