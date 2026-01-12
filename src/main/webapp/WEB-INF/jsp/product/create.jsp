<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.nettenz.ebay.dao.DepartmentDao.DepartmentRecord" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>List Item</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body class="centered">
<div class="card" style="max-width: 520px; width: 90%;">
    <div class="card-header">
        <h2>List a New Item</h2>
    </div>

    <% String err = (String) request.getAttribute("error"); %>
    <% if (err != null) { %>
    <div class="alert alert-error"><%= err %></div>
    <% } %>

    <form method="post" action="<%=request.getContextPath()%>/products/new" enctype="multipart/form-data">
        <div class="form-group">
            <label class="form-label" for="name">Product Title</label>
            <input type="text" id="name" name="name" required class="form-input" placeholder="e.g. Vintage Camera">
        </div>

        <div class="form-group">
            <label class="form-label" for="imageFile">Product Image</label>
            <input type="file" id="imageFile" name="imageFile" accept="image/*" class="form-input">
            <div class="text-muted text-sm mt-1">Or provide a URL:</div>
            <input type="url" id="imageUrl" name="imageUrl" class="form-input mt-1" placeholder="https://example.com/image.jpg">
        </div>

        <div class="form-group">
            <label class="form-label" for="departmentId">Department</label>
            <select id="departmentId" name="departmentId" class="form-input">
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
            <label class="form-label" for="startingBid">Starting Bid ($)</label>
            <input type="number" id="startingBid" name="startingBid" step="0.01" min="0" required class="form-input" placeholder="0.00">
        </div>

        <div class="form-group">
            <label class="form-label" for="description">Description</label>
            <textarea id="description" name="description" class="form-input" placeholder="Describe your item..."></textarea>
        </div>

        <button type="submit" class="btn btn-primary btn-block">Create Listing</button>
    </form>

    <div class="text-center mt-2">
        <a href="<%=request.getContextPath()%>/products" class="text-muted text-sm">Cancel</a>
    </div>
</div>
</body>
</html>
