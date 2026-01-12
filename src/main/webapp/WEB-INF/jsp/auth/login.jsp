<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Login</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body class="centered">
<div class="card" style="max-width: 380px; width: 90%;">
    <div class="card-header text-center">
        <h2>Sign In</h2>
    </div>

    <% String err = (String) request.getAttribute("error"); %>
    <% if (err != null) { %>
    <div class="alert alert-error"><%= err %></div>
    <% } %>

    <% if (request.getParameter("registered") != null) { %>
    <div class="alert alert-success">Registration successful! Please log in.</div>
    <% } %>

    <form method="post" action="<%=request.getContextPath()%>/login">
        <div class="form-group">
            <label class="form-label" for="username">Username</label>
            <input id="username" name="username" required class="form-input" placeholder="Enter username"/>
        </div>

        <div class="form-group">
            <label class="form-label" for="password">Password</label>
            <input id="password" name="password" type="password" required class="form-input" placeholder="Enter password"/>
        </div>

        <input type="hidden" name="returnTo" value="<%= request.getParameter("returnTo") == null ? "" : request.getParameter("returnTo") %>"/>

        <button type="submit" class="btn btn-primary btn-block">Sign In</button>
    </form>

    <div class="text-center mt-2 text-sm">
        <span class="text-muted">Don't have an account?</span> <a href="<%=request.getContextPath()%>/register">Sign up</a>
    </div>
</div>
</body>
</html>
