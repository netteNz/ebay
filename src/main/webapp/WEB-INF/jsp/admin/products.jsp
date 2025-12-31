<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.nettenz.ebay.dao.ProductDao.ProductDto" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Manage Products - Admin</title>
    <style>
        body { font-family: system-ui, sans-serif; background: #f4f7f6; margin: 0; display: flex; }
        .sidebar { width: 260px; background: #2c3e50; color: white; min-height: 100vh; padding: 30px 20px; }
        .sidebar a { display: block; color: #bdc3c7; text-decoration: none; padding: 12px; margin-bottom: 8px; border-radius: 4px; }
        .sidebar a:hover, .sidebar a.active { background: #34495e; color: white; }
        
        .main { flex: 1; padding: 40px; }
        h1 { margin-top: 0; color: #2c3e50; }
        
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #ecf0f1; font-weight: 600; color: #7f8c8d; }
        
        .img-thumb { width: 50px; height: 50px; object-fit: cover; border-radius: 4px; background: #eee; }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>Admin Panel</h2>
    <a href="<%=request.getContextPath()%>/admin/dashboard">🏠 Dashboard</a>
    <a href="<%=request.getContextPath()%>/admin/users">👥 Users</a>
    <a href="<%=request.getContextPath()%>/admin/products" class="active">📦 Products</a>
    <a href="<%=request.getContextPath()%>/admin/departments">📑 Departments</a>
</div>

<div class="main">
    <h1>Manage Products</h1>
    
    <table>
        <thead>
            <tr>
                <th>Image</th>
                <th>Title</th>
                <th>Seller</th>
                <th>Starting Bid</th>
                <th>Listed At</th>
            </tr>
        </thead>
        <tbody>
            <%
                List<ProductDto> list = (List<ProductDto>) request.getAttribute("products");
                if (list != null) {
                    for (ProductDto p : list) {
                        String img = p.imageUrl();
                        String displayImg = null;
                        if (img != null && !img.isBlank()) {
                            if (img.startsWith("http")) displayImg = img;
                            else if (img.startsWith("/images/")) displayImg = request.getContextPath() + img;
                        }
            %>
            <tr>
                <td>
                    <% if (displayImg != null) { %>
                        <img src="<%= displayImg %>" class="img-thumb">
                    <% } else { %>
                        <div class="img-thumb"></div>
                    <% } %>
                </td>
                <td><%= p.name() %></td>
                <td><%= p.sellerName() %></td>
                <td>$<%= p.currentPrice() %></td>
                <td><%= p.createdAt() %></td>
            </tr>
            <%
                    }
                }
            %>
        </tbody>
    </table>
</div>

</body>
</html>
