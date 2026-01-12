<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.nettenz.ebay.dao.ProductDao.ProductDto" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Manage Products</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
<div class="layout-sidebar">
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="sidebar-title">Admin Panel</div>
        </div>
        <nav class="sidebar-nav">
            <a href="<%=request.getContextPath()%>/admin/dashboard" class="sidebar-link">Dashboard</a>
            <a href="<%=request.getContextPath()%>/admin/users" class="sidebar-link">Users</a>
            <a href="<%=request.getContextPath()%>/admin/products" class="sidebar-link active">Products</a>
            <a href="<%=request.getContextPath()%>/admin/departments" class="sidebar-link">Departments</a>
            <a href="<%=request.getContextPath()%>/logout" class="sidebar-link sidebar-link-danger mt-3">Logout</a>
        </nav>
    </aside>

    <main class="main-content">
        <div class="page-header">
            <div class="page-header-text">
                <h1>Products</h1>
                <p>Manage auction listings</p>
            </div>
        </div>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Image</th>
                        <th>Title</th>
                        <th>Seller</th>
                        <th>Starting Bid</th>
                        <th>Listed</th>
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
                        <td class="mono">$<%= p.currentPrice() %></td>
                        <td class="text-muted"><%= p.createdAt() %></td>
                    </tr>
                    <%
                            }
                        }
                    %>
                </tbody>
            </table>
        </div>
    </main>
</div>
</body>
</html>
