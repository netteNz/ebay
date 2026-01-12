<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.nettenz.ebay.dao.DepartmentDao.DepartmentRecord" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Manage Departments</title>
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
            <a href="<%=request.getContextPath()%>/admin/products" class="sidebar-link">Products</a>
            <a href="<%=request.getContextPath()%>/admin/departments" class="sidebar-link active">Departments</a>
            <a href="<%=request.getContextPath()%>/logout" class="sidebar-link sidebar-link-danger mt-3">Logout</a>
        </nav>
    </aside>

    <main class="main-content">
        <div class="page-header">
            <div class="page-header-text">
                <h1>Departments</h1>
                <p>Manage product categories</p>
            </div>
        </div>

        <div class="flex gap-3" style="flex-wrap: wrap;">
            <div style="flex: 2; min-width: 300px;">
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Department Name</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                List<DepartmentRecord> list = (List<DepartmentRecord>) request.getAttribute("departments");
                                if (list != null) {
                                    for (DepartmentRecord d : list) {
                            %>
                            <tr>
                                <td class="mono"><%= d.id() %></td>
                                <td><%= d.name() %></td>
                            </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div style="flex: 1; min-width: 280px;">
                <div class="card card-sm">
                    <h3>Add Department</h3>
                    <form method="post" action="<%=request.getContextPath()%>/admin/departments" class="mt-2">
                        <div class="form-group">
                            <label class="form-label">Name</label>
                            <input type="text" name="name" required class="form-input" placeholder="e.g. Antiques">
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Add</button>
                    </form>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
