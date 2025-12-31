<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Admin Dashboard - eBay Auction</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: system-ui, -apple-system, Arial, sans-serif;
            background: #f4f7f6;
            display: flex;
            min-height: 100vh;
        }
        .sidebar {
            width: 260px;
            background: #2c3e50;
            color: white;
            padding: 30px 20px;
        }
        .sidebar h2 { margin-bottom: 30px; font-size: 1.5em; text-align: center; }
        .sidebar a {
            display: block;
            color: #bdc3c7;
            text-decoration: none;
            padding: 12px 15px;
            border-radius: 6px;
            margin-bottom: 8px;
            transition: all 0.3s;
        }
        .sidebar a:hover, .sidebar a.active {
            background: #34495e;
            color: white;
        }
        .main-content {
            flex: 1;
            padding: 40px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        }
        .stat-card h3 { color: #7f8c8d; font-size: 0.9em; text-transform: uppercase; margin-bottom: 10px; }
        .stat-card .value { font-size: 1.8em; font-weight: bold; color: #2c3e50; }
        .btn-home {
            background: #667eea;
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2>Admin Panel</h2>
        <a href="<%=request.getContextPath()%>/admin/dashboard" class="active">🏠 Dashboard</a>
        <a href="<%=request.getContextPath()%>/admin/users">👥 Users</a>
        <a href="<%=request.getContextPath()%>/admin/products">📦 Products</a>
        <a href="<%=request.getContextPath()%>/admin/departments">📑 Departments</a>
        <a href="<%=request.getContextPath()%>/logout" style="margin-top: 50px; color: #e74c3c;">🚪 Logout</a>
    </div>

<%@ page import="com.nettenz.ebay.dao.StatsDao.DashboardStats" %>
    <div class="main-content">
        <div class="header">
            <h1>Dashboard Overview</h1>
            <a href="<%=request.getContextPath()%>/ " class="btn-home">Back to Home</a>
        </div>

        <%
            DashboardStats stats = (DashboardStats) request.getAttribute("stats");
            long userCount = stats != null ? stats.userCount() : 0;
            long productCount = stats != null ? stats.productCount() : 0;
            long bidCount = stats != null ? stats.bidCount() : 0;
        %>

        <div class="stats-grid">
            <div class="stat-card">
                <h3>Total Users</h3>
                <div class="value"><%= userCount %></div>
            </div>
            <div class="stat-card">
                <h3>Active Auctions</h3>
                <div class="value"><%= productCount %></div>
            </div>
            <div class="stat-card">
                <h3>Total Bids</h3>
                <div class="value"><%= bidCount %></div>
            </div>
            <div class="stat-card">
                <h3>Revenue</h3>
                <div class="value">$0.00</div>
            </div>
        </div>

        <div style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
            <h3>System Status</h3>
            <p style="margin-top: 15px; color: #666;">
                Welcome to the administration area. From here you can manage all aspects of the eBay Auction platform.
                Functional modules for user management and product moderation will be available soon.
            </p>
        </div>
    </div>
</body>
</html>
