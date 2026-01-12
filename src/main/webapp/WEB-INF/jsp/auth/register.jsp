<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Register</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body class="centered">
<div class="card" style="max-width: 380px; width: 90%;">
    <div class="card-header text-center">
        <h2>Create Account</h2>
    </div>

    <% String err = (String) request.getAttribute("error"); %>
    <% if (err != null) { %>
    <div class="alert alert-error"><%= err %></div>
    <% } %>

    <form method="post" action="<%=request.getContextPath()%>/register">
        <div class="form-group">
            <label class="form-label" for="username">Username</label>
            <input id="username" name="username" value="${param.username}" required class="form-input" placeholder="Choose a username"/>
        </div>

        <div class="form-group">
            <label class="form-label" for="password">Password</label>
            <input id="password" name="password" type="password" required class="form-input" placeholder="Create a password"/>
        </div>

        <div class="form-group">
            <label class="form-label" for="confirmPassword">Confirm Password</label>
            <input id="confirmPassword" name="confirmPassword" type="password" required class="form-input" placeholder="Confirm your password"/>
        </div>

        <button type="submit" class="btn btn-primary btn-block">Sign Up</button>
    </form>

    <div class="text-center mt-2 text-sm">
        <span class="text-muted">Already have an account?</span> <a href="<%=request.getContextPath()%>/login">Log in</a>
    </div>
</div>
</body>
</html>
