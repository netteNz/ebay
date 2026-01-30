# Deployment Guide

## Build
```bash
mvn clean package
# Output: target/ebay-1.0-SNAPSHOT.war
```

## Runtime Environment
Deploy the WAR file to any **Tomcat 10.1+** (Jakarta EE 10) server.

### Configuration (Environment Variables)
Set these on your server or container:

| Variable | Default (Code) | Description |
| :--- | :--- | :--- |
| `DB_HOST` | `localhost` | Database hostname |
| `DB_PORT` | `3306` | Database port |
| `DB_NAME` | `ebay` | Database name |
| `DB_USER` | `root` | Database username |
| `DB_PASSWORD` | *(empty)* | Database password |

## Database Initialization
Ensure the database schema is loaded before starting the app:
```bash
mysql -u $DB_USER -p $DB_NAME < db/schema.sql
```

## Production Tips
1.  **HTTPS**: Configure SSL at the Tomcat connector or via a reverse proxy (Nginx).
2.  **Heap**: Set `CATALINA_OPTS="-Xmx2G"` minimum.
3.  **Security**: Change the default admin password immediately.
