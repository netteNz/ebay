package com.nettenz.ebay.servlet.admin.product;

import com.nettenz.ebay.dao.DepartmentDao;
import com.nettenz.ebay.dao.ProductDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.util.UUID;

@WebServlet("/products/new")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024, // 1 MB
        maxFileSize = 1024 * 1024 * 10,  // 10 MB
        maxRequestSize = 1024 * 1024 * 15 // 15 MB
)
public class CreateProductServlet extends HttpServlet {

    private final ProductDao productDao = new ProductDao();
    private final DepartmentDao departmentDao = new DepartmentDao();
    private static final String UPLOAD_DIR = "C:\\Users\\Emanuel\\IdeaProjects\\ebay\\uploads";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Populate departments for the dropdown
        req.setAttribute("departments", departmentDao.findAll());
        req.getRequestDispatcher("/WEB-INF/jsp/product/create.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("auth.userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Long sellerId = (Long) session.getAttribute("auth.userId");
        String name = req.getParameter("name");
        String description = req.getParameter("description");
        String deptIdStr = req.getParameter("departmentId");
        String startBidStr = req.getParameter("startingBid");
        
        // Handle File Upload
        Part filePart = req.getPart("imageFile");
        String imageUrl = req.getParameter("imageUrl"); // Fallback URL

        if (isEmpty(name) || isEmpty(startBidStr)) {
            req.setAttribute("error", "Name and Starting Bid are required.");
            doGet(req, resp);
            return;
        }

        try {
            // Process Image
            String finalImageIdentifier = null;
            
            // Priority 1: File Upload
            if (filePart != null && filePart.getSize() > 0 && filePart.getSubmittedFileName() != null && !filePart.getSubmittedFileName().isBlank()) {
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
                
                // Ensure dir exists
                File uploadDir = new File(UPLOAD_DIR);
                if (!uploadDir.exists()) uploadDir.mkdirs();
                
                // Write file
                filePart.write(UPLOAD_DIR + File.separator + uniqueFileName);
                
                // Store relative path identifier
                finalImageIdentifier = "/images/" + uniqueFileName;
                
            } else if (!isEmpty(imageUrl)) {
                // Priority 2: External URL
                finalImageIdentifier = imageUrl;
            }

            Long departmentId = (deptIdStr != null && !deptIdStr.isBlank()) ? Long.valueOf(deptIdStr) : null;
            BigDecimal startingBid = new BigDecimal(startBidStr);

            productDao.create(sellerId, departmentId, name, description, finalImageIdentifier, startingBid);

            resp.sendRedirect(req.getContextPath() + "/products");

        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid number format.");
            doGet(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Error processing request: " + e.getMessage());
            e.printStackTrace();
            doGet(req, resp);
        }
    }

    private boolean isEmpty(String s) {
        return s == null || s.isBlank();
    }
}
