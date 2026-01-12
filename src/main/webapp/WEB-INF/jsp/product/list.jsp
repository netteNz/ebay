<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.nettenz.ebay.dao.ProductDao.ProductDto" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Products</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>

<nav class="nav">
    <a href="<%=request.getContextPath()%>/" class="nav-brand">Auction</a>
    <div class="nav-links">
        <% if (session.getAttribute("auth.userId") != null) { %>
            <span class="nav-user"><%= session.getAttribute("auth.username") %></span>
            <a href="<%=request.getContextPath()%>/logout">Logout</a>
        <% } else { %>
            <a href="<%=request.getContextPath()%>/login">Login</a>
        <% } %>
    </div>
</nav>

<div class="container-wide">
    <div class="page-header">
        <div class="page-header-text">
            <h1>Active Auctions</h1>
            <p>Discover unique items and place your bids</p>
        </div>
        <% if (session.getAttribute("auth.userId") != null) { %>
            <a href="<%=request.getContextPath()%>/products/new" class="btn btn-primary">+ List Item</a>
        <% } %>
    </div>

    <div class="grid grid-auto">
        <%
            List<ProductDto> products = (List<ProductDto>) request.getAttribute("products");
            if (products == null || products.isEmpty()) {
        %>
            <div class="empty-state" style="grid-column: 1/-1;">
                <div class="empty-state-icon">📦</div>
                <h3>No products found</h3>
                <p>Be the first to list an item!</p>
            </div>
        <%
            } else {
                for (ProductDto p : products) {
        %>
            <a href="<%=request.getContextPath()%>/products/<%= p.id() %>" class="product-card" style="text-decoration: none; color: inherit;">
                <% 
                   String img = p.imageUrl();
                   String displayImg = null;
                   if (img != null && !img.isBlank()) {
                       if (img.startsWith("http")) {
                           displayImg = img;
                       } else if (img.startsWith("/images/")) {
                           displayImg = request.getContextPath() + img;
                       } else {
                           displayImg = img;
                       }
                   }
                %>
                <% if (displayImg != null) { %>
                    <img src="<%= displayImg %>" alt="<%= p.name() %>" class="product-img">
                <% } else { %>
                    <div class="product-placeholder">📦</div>
                <% } %>
                
                <div class="product-body">
                    <div class="product-title"><%= p.name() %></div>
                    <div class="product-desc"><%= p.description() != null ? p.description() : "" %></div>
                    <div class="product-price">$<%= p.currentPrice() %></div>
                    <div class="product-meta"><%= p.bidCount() %> bid<%= p.bidCount() != 1 ? "s" : "" %> · <%= p.sellerName() %></div>
                </div>
            </a>
        <%
                }
            }
        %>
    </div>
</div>

</body>
</html>
