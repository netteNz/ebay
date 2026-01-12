<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.nettenz.ebay.dao.ProductDao.ProductDto" %>
<%@ page import="com.nettenz.ebay.dao.BidDao.BidDto" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title><%= ((ProductDto)request.getAttribute("product")).name() %> - Auction</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <style>
        .product-detail {
            display: grid;
            grid-template-columns: 1.2fr 1fr;
            gap: 2.5rem;
            align-items: start;
        }
        .product-image-wrapper {
            background: var(--bg-secondary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
        }
        .product-image {
            width: 100%;
            max-height: 500px;
            object-fit: contain;
            border-radius: var(--radius-md);
            background: var(--bg-tertiary);
        }
        .product-image-placeholder {
            width: 100%;
            aspect-ratio: 4/3;
            background: var(--bg-tertiary);
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 5rem;
            color: var(--text-muted);
        }
        .product-info {
            background: var(--bg-secondary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: 1.75rem;
        }
        .product-info h1 {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
        }
        .product-seller {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.375rem 0.75rem;
            background: var(--bg-tertiary);
            border-radius: var(--radius-sm);
            font-size: 0.85rem;
            color: var(--text-secondary);
        }
        .product-seller strong {
            color: var(--text-primary);
        }
        .bid-section {
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 1px solid var(--border-subtle);
        }
        .bid-label {
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            color: var(--text-muted);
            margin-bottom: 0.25rem;
        }
        .current-bid {
            font-size: 2.25rem;
            font-weight: 700;
            color: var(--success);
            font-family: var(--font-mono);
        }
        .starting-bid {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            color: var(--text-muted);
            font-size: 0.85rem;
            margin-top: 0.5rem;
        }
        .starting-bid .divider {
            width: 4px;
            height: 4px;
            background: var(--text-muted);
            border-radius: 50%;
        }
        .bid-input {
            display: flex;
            gap: 0.5rem;
            margin-top: 1.25rem;
        }
        .bid-input input {
            flex: 1;
        }
        .bid-hint {
            font-size: 0.8rem;
            color: var(--text-muted);
            margin-top: 0.5rem;
        }
        .detail-section {
            margin-top: 2.5rem;
        }
        .detail-section-header {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 1rem;
        }
        .detail-section-header h3 {
            font-size: 1rem;
            margin-bottom: 0;
        }
        .detail-section-header::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--border-color);
        }
        .description-card {
            background: var(--bg-secondary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
        }
        .description-content {
            line-height: 1.8;
            color: var(--text-secondary);
            white-space: pre-wrap;
        }
        .description-empty {
            color: var(--text-muted);
            font-style: italic;
        }
        .bid-history {
            margin-top: 2.5rem;
        }
        .bid-history h3 {
            font-size: 1rem;
            margin-bottom: 1rem;
        }
        .bid-history h3 {
            font-size: 1rem;
            margin-bottom: 1rem;
        }
        .bid-history-card {
            background: var(--bg-secondary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            overflow: hidden;
        }
        .bid-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 1.25rem;
            border-bottom: 1px solid var(--border-subtle);
            transition: background 0.15s;
        }
        .bid-item:hover {
            background: var(--bg-tertiary);
        }
        .bid-item:last-child {
            border-bottom: none;
        }
        .bid-item-info {
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
        }
        .bid-item-name {
            font-weight: 600;
            color: var(--text-primary);
        }
        .bid-meta {
            color: var(--text-muted);
            font-size: 0.8rem;
        }
        .bid-amount {
            font-family: var(--font-mono);
            font-size: 1.1rem;
            color: var(--success);
            font-weight: 600;
        }
        @media (max-width: 900px) {
            .product-detail {
                grid-template-columns: 1fr;
            }
            .product-image {
                max-height: 400px;
            }
        }
    </style>
</head>
<body>

<nav class="nav">
    <a href="<%=request.getContextPath()%>/" class="nav-brand">Auction</a>
    <div class="nav-links">
        <a href="<%=request.getContextPath()%>/products">Products</a>
        <% if (session.getAttribute("auth.userId") != null) { %>
            <span class="nav-user"><%= session.getAttribute("auth.username") %></span>
            <a href="<%=request.getContextPath()%>/logout">Logout</a>
        <% } else { %>
            <a href="<%=request.getContextPath()%>/login">Login</a>
        <% } %>
    </div>
</nav>

<%
    ProductDto product = (ProductDto) request.getAttribute("product");
    List<BidDto> bidHistory = (List<BidDto>) request.getAttribute("bidHistory");
    SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy 'at' h:mm a");
    
    Long userId = (Long) session.getAttribute("auth.userId");
    boolean isLoggedIn = userId != null;
    boolean isSeller = isLoggedIn && userId.equals(product.sellerId());
    
    // Get flash messages
    String bidError = (String) session.getAttribute("bidError");
    String bidSuccess = (String) session.getAttribute("bidSuccess");
    session.removeAttribute("bidError");
    session.removeAttribute("bidSuccess");
    
    String img = product.imageUrl();
    String displayImg = null;
    if (img != null && !img.isBlank()) {
        if (img.startsWith("http")) displayImg = img;
        else if (img.startsWith("/images/")) displayImg = request.getContextPath() + img;
        else displayImg = img;
    }
%>

<div class="container">
    <div class="mb-2">
        <a href="<%=request.getContextPath()%>/products" class="text-muted text-sm">&larr; Back to listings</a>
    </div>

    <% if (bidError != null) { %>
    <div class="alert alert-error"><%= bidError %></div>
    <% } %>
    <% if (bidSuccess != null) { %>
    <div class="alert alert-success"><%= bidSuccess %></div>
    <% } %>

    <div class="product-detail">
        <div class="product-image-wrapper">
            <% if (displayImg != null) { %>
                <img src="<%= displayImg %>" alt="<%= product.name() %>" class="product-image">
            <% } else { %>
                <div class="product-image-placeholder">📦</div>
            <% } %>
        </div>

        <div class="product-info">
            <h1><%= product.name() %></h1>
            <div class="product-seller">
                Listed by <strong><%= product.sellerName() %></strong>
            </div>
            
            <div class="bid-section">
                <div class="bid-label">Current Bid</div>
                <div class="current-bid">$<%= product.currentPrice() %></div>
                <div class="starting-bid">
                    <span>Started at $<%= product.startingBid() %></span>
                    <span class="divider"></span>
                    <span><%= product.bidCount() %> bid<%= product.bidCount() != 1 ? "s" : "" %></span>
                </div>

                <% if (!isLoggedIn) { %>
                    <div class="mt-2">
                        <a href="<%=request.getContextPath()%>/login?returnTo=/products/<%= product.id() %>" class="btn btn-outline btn-block">Login to Place Bid</a>
                    </div>
                <% } else if (isSeller) { %>
                    <div class="alert alert-info mt-2">You cannot bid on your own item</div>
                <% } else { %>
                    <form method="post" action="<%=request.getContextPath()%>/bid" class="bid-input">
                        <input type="hidden" name="productId" value="<%= product.id() %>">
                        <input type="number" name="amount" step="0.01" min="<%= product.currentPrice().add(new java.math.BigDecimal("0.01")) %>" 
                               class="form-input" placeholder="Enter bid amount" required>
                        <button type="submit" class="btn btn-primary">Place Bid</button>
                    </form>
                    <div class="bid-hint">Enter more than $<%= product.currentPrice() %></div>
                <% } %>
            </div>
        </div>
    </div>

    <div class="detail-section">
        <div class="detail-section-header">
            <h3>About this item</h3>
        </div>
        <div class="description-card">
            <% if (product.description() != null && !product.description().isBlank()) { %>
                <div class="description-content"><%= product.description() %></div>
            <% } else { %>
                <div class="description-empty">No description provided for this item.</div>
            <% } %>
        </div>
    </div>

    <% if (!bidHistory.isEmpty()) { %>
    <div class="detail-section">
        <div class="detail-section-header">
            <h3>Bid History</h3>
        </div>
        <div class="bid-history-card">
            <% for (BidDto bid : bidHistory) { %>
            <div class="bid-item">
                <div class="bid-item-info">
                    <span class="bid-item-name"><%= bid.bidderName() %></span>
                    <span class="bid-meta"><%= sdf.format(bid.createdAt()) %></span>
                </div>
                <div class="bid-amount">$<%= bid.amount() %></div>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>
</div>

</body>
</html>
