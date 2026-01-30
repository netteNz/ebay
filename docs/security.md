# Security Overview

## Implemented Measures

### Authentication
*   **BCrypt Hashing**: 12 rounds, automatic salt.
    *   `BCrypt.hashpw(password, BCrypt.gensalt(12))`
*   **Session Management**: standard HttpSession with `HttpOnly` cookies.
*   **RBAC**: Servo filter-based Role-Based Access Control (`User` vs `Admin`).

### Data Safety
*   **SQL Injection**: 100% usage of `PreparedStatement` in all DAOs.
*   **Input**: Basic type validation at Servlet layer.

## Active Vulnerabilities / TODOs

### 🔴 Critical
*   **CSRF**: No token validation on POST requests.
*   **XSS**: No output sanitization (OWASP Java HTML Sanitizer needed).
*   **HTTPS**: Not enforced at app level (must be handled by proxy/server).

### 🟡 Warning
*   **Rate Limiting**: None. Brute force possible on login.
*   **Audit Logs**: Minimal. Admin actions are not persistently logged.
*   **File Uploads**: Basic extension checks only. No malware scan.

## Incident Response
If a breach is detected:
1.  Isolate the Tomcat instance.
2.  Rotate all DB passwords.
3.  Notify `emanuel@nettenz.com`.
