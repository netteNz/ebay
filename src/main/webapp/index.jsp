<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Auction</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body class="centered">
<div class="card" style="max-width: 420px; width: 90%;">
    <div class="text-center mb-3">
        <h1>Auction</h1>
        <p>Modern auction platform</p>
    </div>

    <%
        String username = (String) session.getAttribute("auth.username");
        String role = (String) session.getAttribute("auth.role");
        Long userId = (Long) session.getAttribute("auth.userId");
    %>

    <% if (username != null) { %>
        <div class="user-info">
            <div class="user-info-name">
                <%= username %>
                <span class="badge <%= role != null && role.equals("ADMIN") ? "badge-admin" : "badge-user" %>">
                    <%= role != null ? role : "USER" %>
                </span>
            </div>
            <div class="user-info-id">ID: <%= userId %></div>
        </div>

        <div class="alert alert-success text-center">Session active</div>

        <div class="flex flex-col gap-1">
            <% if ("ADMIN".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/admin/dashboard" class="btn btn-primary btn-block">Admin Dashboard</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/products" class="btn btn-primary btn-block">Browse Products</a>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-secondary btn-block">Logout</a>
        </div>

    <% } else { %>
        <form method="post" action="<%=request.getContextPath()%>/login">
            <div class="form-group">
                <label class="form-label">Username</label>
                <input name="username" required class="form-input" placeholder="Enter username">
            </div>
            <div class="form-group">
                <label class="form-label">Password</label>
                <input name="password" type="password" required class="form-input" placeholder="Enter password">
            </div>
            <button type="submit" class="btn btn-primary btn-block">Sign In</button>
        </form>
        
        <div class="text-center mt-2 text-sm">
            <span class="text-muted">New here?</span> <a href="<%=request.getContextPath()%>/register">Create an account</a>
        </div>
    <% } %>
</div>
</body>
</html>
