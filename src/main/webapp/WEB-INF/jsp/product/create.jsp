<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.nettenz.ebay.dao.DepartmentDao.DepartmentRecord" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>List New Item - eBay Auction</title>
    <style>
        body {
            font-family: system-ui, -apple-system, Arial, sans-serif;
            background: #f4f7f6;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            width: 90%;
            max-width: 600px;
        }
        h2 { margin-top: 0; color: #2c3e50; border-bottom: 2px solid #eee; padding-bottom: 15px; margin-bottom: 25px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: 600; color: #555; }
        input[type="text"], input[type="number"], input[type="url"], textarea, select {
            width: 100%;
            padding: 12px;
            box-sizing: border-box;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 16px;
            transition: border-color 0.2s;
        }
        input:focus, textarea:focus, select:focus { border-color: #667eea; outline: none; }
        textarea { resize: vertical; min-height: 100px; }
        .btn {
            background: #667eea;
            color: white;
            padding: 14px 20px;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
            transition: background 0.2s;
        }
        .btn:hover { background: #5568d3; }
        .back-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            color: #777;
            text-decoration: none;
        }
        .back-link:hover { color: #333; }
        .error { color: #c0392b; background: #fadbd8; padding: 10px; border-radius: 5px; margin-bottom: 20px; }
    </style>
</head>
<body>
<div class="container">
    <h2>List a New Item</h2>

    <% String err = (String) request.getAttribute("error"); %>
    <% if (err != null) { %>
    <div class="error"><%= err %></div>
    <% } %>

    <form method="post" action="<%=request.getContextPath()%>/products/new" enctype="multipart/form-data">
        <div class="form-group">
            <label for="name">Product Title</label>
            <input type="text" id="name" name="name" required placeholder="e.g. Vintage Camera">
        </div>

        <div class="form-group">
            <label for="imageFile">Product Image</label>
            <input type="file" id="imageFile" name="imageFile" accept="image/*">
            <div style="margin-top: 5px; font-size: 0.9em; color: #777;">Or provide a URL below:</div>
            <input type="url" id="imageUrl" name="imageUrl" placeholder="https://example.com/image.jpg" style="margin-top: 5px;">
        </div>

        <div class="form-group">
            <label for="departmentId">Department</label>
            <select id="departmentId" name="departmentId">
                <option value="">-- Select Department --</option>
                <%
                    List<DepartmentRecord> depts = (List<DepartmentRecord>) request.getAttribute("departments");
                    if (depts != null) {
                        for (DepartmentRecord d : depts) {
                %>
                    <option value="<%= d.id() %>"><%= d.name() %></option>
                <%
                        }
                    }
                %>
            </select>
        </div>

        <div class="form-group">
            <label for="startingBid">Starting Bid ($)</label>
            <input type="number" id="startingBid" name="startingBid" step="0.01" min="0" required placeholder="0.00">
        </div>

        <div class="form-group">
            <label for="description">Description (Optional)</label>
            <textarea id="description" name="description" placeholder="Describe your item..."></textarea>
        </div>

        <button type="submit" class="btn">Create Listing</button>
    </form>

    <a href="<%=request.getContextPath()%>/products" class="back-link">Cancel and return to list</a>
</div>
</body>
</html>
