<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.nettenz.ebay.dao.AdminDao.UserDto" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Manage Users - Admin</title>
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
        tr:last-child td { border-bottom: none; }
        .role-badge { padding: 4px 8px; border-radius: 12px; font-size: 0.8em; font-weight: bold; }
        .role-ADMIN { background: #fab1a0; color: #d35400; }
        .role-USER { background: #a29bfe; color: #2d3436; }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>Admin Panel</h2>
    <a href="<%=request.getContextPath()%>/admin/dashboard">🏠 Dashboard</a>
    <a href="<%=request.getContextPath()%>/admin/users" class="active">👥 Users</a>
    <a href="<%=request.getContextPath()%>/admin/products">📦 Products</a>
    <a href="<%=request.getContextPath()%>/admin/departments">📑 Departments</a>
</div>

<div class="main">
    <h1>Manage Users</h1>
    
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Username</th>
                <th>Email</th>
                <th>Role</th>
                <th>Joined</th>
            </tr>
        </thead>
        <tbody>
            <%
                List<UserDto> users = (List<UserDto>) request.getAttribute("users");
                if (users != null) {
                    for (UserDto u : users) {
            %>
            <tr>
                <td><%= u.id() %></td>
                <td><%= u.username() %></td>
                <td><%= u.email() != null ? u.email() : "-" %></td>
                <td>
                    <span class="role-badge role-<%= u.role() %>"><%= u.role() %></span>
                </td>
                <td><%= u.joinedAt() %></td>
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
