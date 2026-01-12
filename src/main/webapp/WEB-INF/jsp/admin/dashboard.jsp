<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.nettenz.ebay.dao.StatsDao.DashboardStats" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
<div class="layout-sidebar">
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="sidebar-title">Admin Panel</div>
        </div>
        <nav class="sidebar-nav">
            <a href="<%=request.getContextPath()%>/admin/dashboard" class="sidebar-link active">Dashboard</a>
            <a href="<%=request.getContextPath()%>/admin/users" class="sidebar-link">Users</a>
            <a href="<%=request.getContextPath()%>/admin/products" class="sidebar-link">Products</a>
            <a href="<%=request.getContextPath()%>/admin/departments" class="sidebar-link">Departments</a>
            <a href="<%=request.getContextPath()%>/logout" class="sidebar-link sidebar-link-danger mt-3">Logout</a>
        </nav>
    </aside>

    <main class="main-content">
        <div class="page-header">
            <div class="page-header-text">
                <h1>Dashboard</h1>
                <p>Overview of your auction platform</p>
            </div>
            <a href="<%=request.getContextPath()%>/" class="btn btn-secondary">Back to Home</a>
        </div>

        <%
            DashboardStats stats = (DashboardStats) request.getAttribute("stats");
            long userCount = stats != null ? stats.userCount() : 0;
            long productCount = stats != null ? stats.productCount() : 0;
            long bidCount = stats != null ? stats.bidCount() : 0;
        %>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total Users</div>
                <div class="stat-value"><%= userCount %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Active Auctions</div>
                <div class="stat-value"><%= productCount %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Total Bids</div>
                <div class="stat-value"><%= bidCount %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Revenue</div>
                <div class="stat-value">$0</div>
            </div>
        </div>

        <div class="card card-sm">
            <h3>System Status</h3>
            <p class="mt-1">All systems operational. Manage users, products, and departments from the sidebar.</p>
        </div>
    </main>
</div>
</body>
</html>
