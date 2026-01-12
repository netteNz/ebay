<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.nettenz.ebay.dao.AdminDao.UserDto" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Manage Users</title>
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
            <a href="<%=request.getContextPath()%>/admin/users" class="sidebar-link active">Users</a>
            <a href="<%=request.getContextPath()%>/admin/products" class="sidebar-link">Products</a>
            <a href="<%=request.getContextPath()%>/admin/departments" class="sidebar-link">Departments</a>
            <a href="<%=request.getContextPath()%>/logout" class="sidebar-link sidebar-link-danger mt-3">Logout</a>
        </nav>
    </aside>

    <main class="main-content">
        <div class="page-header">
            <div class="page-header-text">
                <h1>Users</h1>
                <p>Manage platform users</p>
            </div>
        </div>

        <div class="table-wrapper">
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
                        <td class="mono"><%= u.id() %></td>
                        <td><%= u.username() %></td>
                        <td><%= u.email() != null ? u.email() : "-" %></td>
                        <td>
                            <span class="badge badge-<%= u.role().toLowerCase() %>"><%= u.role() %></span>
                        </td>
                        <td class="text-muted"><%= u.joinedAt() %></td>
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
