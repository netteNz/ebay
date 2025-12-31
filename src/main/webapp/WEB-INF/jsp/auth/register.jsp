<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Register - eBay Auction</title>
    <style>
        body {
            font-family: system-ui, -apple-system, Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
        }
        .card {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            width: 90%;
            max-width: 420px;
        }
        h2 { margin-top: 0; color: #333; text-align: center; margin-bottom: 25px; }
        .row { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: 500; color: #495057; }
        input {
            width: 100%;
            padding: 12px;
            box-sizing: border-box;
            border: 2px solid #e9ecef;
            border-radius: 6px;
            font-size: 16px;
            transition: border-color 0.2s;
        }
        input:focus { border-color: #667eea; outline: none; }
        button {
            width: 100%;
            padding: 14px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
            margin-top: 10px;
        }
        button:hover { background: #5568d3; }
        .error {
            background: #ffe3e3;
            color: #c92a2a;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 0.9em;
        }
        .links {
            text-align: center;
            margin-top: 20px;
            font-size: 0.95em;
        }
        .links a { color: #667eea; text-decoration: none; font-weight: 500; }
        .links a:hover { text-decoration: underline; }
    </style>
</head>
<body>
<div class="card">
    <h2>Create Account</h2>

    <% String err = (String) request.getAttribute("error"); %>
    <% if (err != null) { %>
    <div class="error"><%= err %></div>
    <% } %>

    <form method="post" action="<%=request.getContextPath()%>/register">
        <div class="row">
            <label for="username">Username</label>
            <input id="username" name="username" value="${param.username}" required />
        </div>

        <div class="row">
            <label for="password">Password</label>
            <input id="password" name="password" type="password" required />
        </div>

        <div class="row">
            <label for="confirmPassword">Confirm Password</label>
            <input id="confirmPassword" name="confirmPassword" type="password" required />
        </div>

        <button type="submit">Sign Up</button>
    </form>

    <div class="links">
        Already have an account? <a href="<%=request.getContextPath()%>/login">Log in</a>
    </div>
</div>
</body>
</html>
