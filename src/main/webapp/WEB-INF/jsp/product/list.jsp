<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.nettenz.ebay.dao.ProductDao.ProductDto" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Browse Products - eBay Auction</title>
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: system-ui, -apple-system, Arial, sans-serif;
            background: #f8f9fa;
            margin: 0;
            padding: 0;
        }
        .navbar {
            background: white;
            padding: 15px 40px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .brand { font-size: 1.5em; font-weight: bold; color: #333; text-decoration: none; }
        .nav-links a { margin-left: 20px; text-decoration: none; color: #555; font-weight: 500; }
        .nav-links a:hover { color: #667eea; }
        
        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }
        .header {
            margin-bottom: 30px;
        }
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 30px;
        }
        .product-card {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            transition: transform 0.2s;
            display: flex;
            flex-direction: column;
        }
        .product-card:hover {
            transform: translateY(-5px);
        }
        .img-placeholder {
            width: 100%;
            height: 200px;
            background: #e9ecef;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #adb5bd;
            font-size: 3em;
        }
        .product-img {
            width: 100%;
            height: 200px;
            object-fit: cover;
        }
        .card-body {
            padding: 20px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        .title { font-size: 1.1em; font-weight: bold; margin-bottom: 10px; color: #2c3e50; }
        .desc { color: #666; font-size: 0.9em; margin-bottom: 15px; flex: 1; }
        .price { font-size: 1.4em; color: #27ae60; font-weight: bold; margin-bottom: 5px; }
        .meta { font-size: 0.8em; color: #999; margin-bottom: 15px; }
        
        .btn {
            display: block;
            width: 100%;
            padding: 10px;
            text-align: center;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 600;
            border: none;
            cursor: pointer;
        }
        .btn-bid { background: #667eea; color: white; }
        .btn-bid:hover { background: #5568d3; }
        .btn-disabled { background: #e9ecef; color: #adb5bd; cursor: not-allowed; }
        .btn-login { background: #fff; border: 1px solid #667eea; color: #667eea; }
        .btn-login:hover { background: #f0f4ff; }
    </style>
</head>
<body>

<nav class="navbar">
    <a href="<%=request.getContextPath()%>/" class="brand">eBay Auction</a>
    <div class="nav-links">
        <% if (session.getAttribute("auth.userId") != null) { %>
            <span>Hello, <%= session.getAttribute("auth.username") %></span>
            <a href="<%=request.getContextPath()%>/logout">Logout</a>
        <% } else { %>
            <a href="<%=request.getContextPath()%>/login">Login</a>
        <% } %>
    </div>
</nav>

<div class="container">
    <div class="header" style="display: flex; justify-content: space-between; align-items: flex-end;">
        <div>
            <h1>Active Auctions</h1>
            <p>Discover unique items and place your bids.</p>
        </div>
        <% if (session.getAttribute("auth.userId") != null) { %>
            <a href="<%=request.getContextPath()%>/products/new" class="btn btn-bid" style="width: auto; padding: 12px 25px;">+ List New Item</a>
        <% } %>
    </div>

    <div class="product-grid">
        <%
            List<ProductDto> products = (List<ProductDto>) request.getAttribute("products");
            if (products == null || products.isEmpty()) {
        %>
            <div style="grid-column: 1/-1; text-align: center; color: #777; padding: 40px;">
                <h3>No products found.</h3>
                <p>Be the first to list an item!</p>
            </div>
        <%
            } else {
                for (ProductDto p : products) {
        %>
            <div class="product-card">
                <% 
                   String img = p.imageUrl();
                   String displayImg = null;
                   if (img != null && !img.isBlank()) {
                       if (img.startsWith("http")) {
                           displayImg = img;
                       } else if (img.startsWith("/images/")) {
                           displayImg = request.getContextPath() + img;
                       } else {
                           displayImg = img; // Fallback
                       }
                   }
                %>
                <% if (displayImg != null) { %>
                    <img src="<%= displayImg %>" alt="<%= p.name() %>" class="product-img">
                <% } else { %>
                    <div class="img-placeholder">📦</div>
                <% } %>
                
                <div class="card-body">
                    <div class="title"><%= p.name() %></div>
                    <div class="desc"><%= p.description() != null ? p.description() : "" %></div>
                    <div class="price">$<%= p.currentPrice() %></div>
                    <div class="meta">Seller: <%= p.sellerName() %></div>
                    
                    <% if (session.getAttribute("auth.userId") != null) { %>
                        <%-- Placeholder for actual bid functionality --%>
                        <button class="btn btn-bid" onclick="alert('Bidding implementation coming soon!')">Place Bid</button>
                    <% } else { %>
                        <a href="<%=request.getContextPath()%>/login?returnTo=/products" class="btn btn-login">Login to Bid</a>
                    <% } %>
                </div>
            </div>
        <%
                }
            }
        %>
    </div>
</div>

</body>
</html>
