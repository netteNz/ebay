<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>eBay Auction - Home</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: system-ui, -apple-system, Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 40px;
            max-width: 600px;
            width: 90%;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .header h1 {
            color: #333;
            font-size: 2em;
            margin-bottom: 10px;
        }
        .header p {
            color: #666;
            font-size: 1.1em;
        }
        .user-info {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 15px 20px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .user-info strong {
            color: #667eea;
        }
        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.85em;
            font-weight: 600;
            margin-left: 10px;
        }
        .badge.admin {
            background: #ff6b6b;
            color: white;
        }
        .badge.user {
            background: #51cf66;
            color: white;
        }
        .actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        .btn {
            flex: 1;
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            font-size: 1em;
            cursor: pointer;
            text-decoration: none;
            text-align: center;
            transition: all 0.3s;
            font-weight: 500;
        }
        .btn-primary {
            background: #667eea;
            color: white;
        }
        .btn-primary:hover {
            background: #5568d3;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }
        .btn-secondary {
            background: #e9ecef;
            color: #495057;
        }
        .btn-secondary:hover {
            background: #dee2e6;
        }
        .welcome-msg {
            text-align: center;
            color: #495057;
            margin: 20px 0;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1>🏛️ eBay Auction</h1>
        <p>Welcome to the Auction Platform</p>
    </div>

    <%
        String username = (String) session.getAttribute("auth.username");
        String role = (String) session.getAttribute("auth.role");
        Long userId = (Long) session.getAttribute("auth.userId");
    %>

    <% if (username != null) { %>
        <div class="user-info">
            <div>👤 <strong>Logged in as:</strong> <%= username %>
                <span class="badge <%= role != null && role.equals("ADMIN") ? "admin" : "user" %>">
                    <%= role != null ? role : "USER" %>
                </span>
            </div>
            <div style="margin-top: 8px; color: #666; font-size: 0.9em;">
                User ID: <%= userId %>
            </div>
        </div>

        <div class="welcome-msg">
            <p>🎉 Authentication successful! Your session is active.</p>
        </div>

        <div class="actions">
            <% if ("ADMIN".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/admin/dashboard" class="btn btn-primary">Admin Dashboard</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/products" class="btn btn-primary">Browse Products</a>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-secondary">Logout</a>
        </div>

    <% } else { %>
        <div class="welcome-msg">
            <p>Please log in to access the auction platform.</p>
        </div>

        <div style="margin-top: 30px; border-top: 1px solid #eee; padding-top: 20px;">
            <form method="post" action="<%=request.getContextPath()%>/login" style="max-width: 320px; margin: 0 auto;">
                <div style="margin-bottom: 15px; text-align: left;">
                    <label style="display:block; margin-bottom:5px; color:#555;">Username</label>
                    <input name="username" required style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
                </div>
                <div style="margin-bottom: 20px; text-align: left;">
                    <label style="display:block; margin-bottom:5px; color:#555;">Password</label>
                    <input name="password" type="password" required style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%;">Sign In</button>
            </form>
            
            <div style="margin-top: 20px; color: #666; font-size: 0.9em;">
                New here? <a href="<%=request.getContextPath()%>/register" style="color: #667eea; text-decoration: none; font-weight: 600;">Create an account</a>
            </div>
        </div>
    <% } %>
</div>
</body>
</html>
