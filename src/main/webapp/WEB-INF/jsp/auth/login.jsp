<%--
  Created by IntelliJ IDEA.
  User: Emanuel
  Date: 12/31/2025
  Time: 3:39 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Login</title>
    <style>
        body { font-family: system-ui, Arial; margin: 40px; }
        .card { max-width: 420px; padding: 20px; border: 1px solid #ddd; border-radius: 10px; }
        .row { margin: 12px 0; }
        label { display:block; margin-bottom:6px; }
        input { width: 100%; padding: 10px; box-sizing: border-box; }
        button { padding: 10px 14px; cursor: pointer; }
        .error { color: #b00020; margin: 10px 0; }
        .muted { color: #666; font-size: 14px; }
    </style>
</head>
<body>
<div class="card">
    <h2>Login</h2>

    <% String err = (String) request.getAttribute("error"); %>
    <% if (err != null) { %>
    <div class="error"><%= err %></div>
    <% } %>

    <form method="post" action="<%=request.getContextPath()%>/login">
        <div class="row">
            <label for="username">Username</label>
            <input id="username" name="username" required />
        </div>

        <div class="row">
            <label for="password">Password</label>
            <input id="password" name="password" type="password" required />
        </div>

        <%-- returnTo preserves the previous page for UX --%>
        <input type="hidden" name="returnTo" value="<%= request.getParameter("returnTo") == null ? "" : request.getParameter("returnTo") %>"/>

        <button type="submit">Sign in</button>
    </form>

    <p class="muted" style="margin-top: 12px;">
        Don’t have an account yet? (We’ll add registration next.)
    </p>
</div>
</body>
</html>
