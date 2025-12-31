<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.nettenz.ebay.dao.DepartmentDao.DepartmentRecord" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Manage Departments - Admin</title>
    <style>
        body { font-family: system-ui, sans-serif; background: #f4f7f6; margin: 0; display: flex; }
        .sidebar { width: 260px; background: #2c3e50; color: white; min-height: 100vh; padding: 30px 20px; }
        .sidebar a { display: block; color: #bdc3c7; text-decoration: none; padding: 12px; margin-bottom: 8px; border-radius: 4px; }
        .sidebar a:hover, .sidebar a.active { background: #34495e; color: white; }
        
        .main { flex: 1; padding: 40px; }
        h1 { margin-top: 0; color: #2c3e50; }
        
        .layout { display: flex; gap: 40px; }
        .list-container { flex: 2; }
        .form-container { flex: 1; background: white; padding: 25px; border-radius: 8px; height: fit-content; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #ecf0f1; font-weight: 600; color: #7f8c8d; }
        
        input { width: 100%; padding: 10px; margin: 10px 0; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background: #667eea; color: white; border: none; border-radius: 4px; cursor: pointer; }
        button:hover { background: #5568d3; }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>Admin Panel</h2>
    <a href="<%=request.getContextPath()%>/admin/dashboard">🏠 Dashboard</a>
    <a href="<%=request.getContextPath()%>/admin/users">👥 Users</a>
    <a href="<%=request.getContextPath()%>/admin/products">📦 Products</a>
    <a href="<%=request.getContextPath()%>/admin/departments" class="active">📑 Departments</a>
</div>

<div class="main">
    <h1>Manage Departments</h1>
    
    <div class="layout">
        <div class="list-container">
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
                        <td><%= d.id() %></td>
                        <td><%= d.name() %></td>
                    </tr>
                    <%
                            }
                        }
                    %>
                </tbody>
            </table>
        </div>
        
        <div class="form-container">
            <h3>Add New Department</h3>
            <form method="post" action="<%=request.getContextPath()%>/admin/departments">
                <label>Name</label>
                <input type="text" name="name" required placeholder="e.g. Antiques">
                <button type="submit">Add Department</button>
            </form>
        </div>
    </div>
</div>

</body>
</html>
