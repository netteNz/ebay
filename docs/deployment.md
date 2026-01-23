# Deployment Guide

Complete guide for deploying the eBay Auction Platform to production.

## Prerequisites

- **Server:** Linux (Ubuntu 20.04+ recommended) or Windows Server
- **Java:** JDK 21
- **Application Server:** Apache Tomcat 10.1+
- **Database:** MySQL 8.x
- **Memory:** Minimum 2GB RAM (4GB+ recommended)
- **Storage:** 10GB+ for application and database

## Build Process

### 1. Clone Repository

```bash
git clone https://github.com/nettenz/ebay.git
cd ebay
```

### 2. Configure Database

Edit database connection settings (if using config file):

```java
// src/main/java/com/nettenz/ebay/db/DatabaseConnection.java
private static final String URL = "jdbc:mysql://your-db-host:3306/ebay";
private static final String USER = "ebay_app";
private static final String PASSWORD = System.getenv("DB_PASSWORD");
```

Or use environment variables (recommended):

```bash
export DB_HOST=your-db-host
export DB_PORT=3306
export DB_NAME=ebay
export DB_USER=ebay_app
export DB_PASSWORD=secure_password
```

### 3. Build WAR File

```bash
mvn clean package
```

Output: `target/ebay-1.0-SNAPSHOT.war`

### 4. Verify Build

```bash
ls -lh target/ebay-1.0-SNAPSHOT.war
# Should show WAR file ~20-50MB
```

## Tomcat Deployment

### Install Tomcat

**Ubuntu:**
```bash
sudo apt update
sudo apt install tomcat10
sudo systemctl enable tomcat10
sudo systemctl start tomcat10
```

**Manual Installation:**
```bash
# Download Tomcat
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.x/bin/apache-tomcat-10.1.x.tar.gz
tar -xzf apache-tomcat-10.1.x.tar.gz
sudo mv apache-tomcat-10.1.x /opt/tomcat

# Set environment
export CATALINA_HOME=/opt/tomcat
```

### Deploy Application

**Option 1: Copy WAR File**
```bash
sudo cp target/ebay-1.0-SNAPSHOT.war $CATALINA_HOME/webapps/
```

Tomcat will auto-deploy the WAR file.

**Option 2: Tomcat Manager**
1. Access: `http://your-server:8080/manager`
2. Upload WAR file via web interface

**Option 3: Direct Unpack**
```bash
sudo unzip target/ebay-1.0-SNAPSHOT.war -d $CATALINA_HOME/webapps/ebay
```

### Verify Deployment

```bash
# Check Tomcat logs
tail -f $CATALINA_HOME/logs/catalina.out

# Look for deployment success message
# "Deployment of web application directory [/path/to/ebay] has finished"
```

Access application:
```
http://your-server:8080/ebay-1.0-SNAPSHOT/
```

## Database Setup (Production)

### Create Production Database

```bash
mysql -u root -p
```

```sql
-- Create database
CREATE DATABASE ebay CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create application user
CREATE USER 'ebay_app'@'localhost' IDENTIFIED BY 'strong_password_here';

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ebay.* TO 'ebay_app'@'localhost';

-- If app server and DB server are different:
CREATE USER 'ebay_app'@'app-server-ip' IDENTIFIED BY 'strong_password_here';
GRANT SELECT, INSERT, UPDATE, DELETE ON ebay.* TO 'ebay_app'@'app-server-ip';

FLUSH PRIVILEGES;
```

### Import Schema

```bash
mysql -u ebay_app -p ebay < db/schema.sql
```

### Change Default Admin Password

```sql
-- Generate new BCrypt hash for new password
-- Use online tool or Java code

UPDATE users
SET password_hash = '$2a$12$NEW_HASH_HERE'
WHERE username = 'admin';
```

## Security Hardening

### 1. Enable HTTPS

**Install Certbot (Let's Encrypt):**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

**Configure Tomcat SSL:**

Edit `$CATALINA_HOME/conf/server.xml`:

```xml
<Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
           maxThreads="150" SSLEnabled="true">
    <SSLHostConfig>
        <Certificate certificateKeystoreFile="/path/to/keystore.jks"
                     certificateKeystorePassword="password"
                     type="RSA" />
    </SSLHostConfig>
</Connector>
```

### 2. Firewall Configuration

```bash
# Allow only necessary ports
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw allow 22/tcp      # SSH
sudo ufw enable

# Block Tomcat port from external access
sudo ufw deny 8080/tcp
```

### 3. Reverse Proxy (Nginx)

**Install Nginx:**
```bash
sudo apt install nginx
```

**Configure:**
```nginx
# /etc/nginx/sites-available/ebay
server {
    listen 80;
    server_name yourdomain.com;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    
    location / {
        proxy_pass http://localhost:8080/ebay-1.0-SNAPSHOT/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Serve static files directly (optional optimization)
    location /static/ {
        alias /opt/tomcat/webapps/ebay-1.0-SNAPSHOT/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

**Enable site:**
```bash
sudo ln -s /etc/nginx/sites-available/ebay /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 4. Environment Variables

Create systemd service file:

```bash
sudo vim /etc/systemd/system/tomcat.service
```

```ini
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment="JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="DB_HOST=localhost"
Environment="DB_PORT=3306"
Environment="DB_NAME=ebay"
Environment="DB_USER=ebay_app"
Environment="DB_PASSWORD=your_secure_password"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
```

Reload and restart:
```bash
sudo systemctl daemon-reload
sudo systemctl restart tomcat
```

## Performance Optimization

### Tomcat Tuning

Edit `$CATALINA_HOME/conf/server.xml`:

```xml
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           maxThreads="200"
           minSpareThreads="25"
           maxConnections="10000"
           acceptCount="100"
           redirectPort="8443" />
```

### JVM Options

Edit `$CATALINA_HOME/bin/setenv.sh`:

```bash
#!/bin/bash
export CATALINA_OPTS="$CATALINA_OPTS -Xms512m"
export CATALINA_OPTS="$CATALINA_OPTS -Xmx2048m"
export CATALINA_OPTS="$CATALINA_OPTS -XX:+UseG1GC"
export CATALINA_OPTS="$CATALINA_OPTS -XX:MaxGCPauseMillis=200"
export CATALINA_OPTS="$CATALINA_OPTS -server"
```

Make executable:
```bash
chmod +x $CATALINA_HOME/bin/setenv.sh
```

### Database Connection Pooling

Already configured with HikariCP (if added to project).

## Monitoring & Logging

### Application Logs

```bash
# Tomcat logs
tail -f $CATALINA_HOME/logs/catalina.out

# Application logs (if using logging framework)
tail -f $CATALINA_HOME/logs/ebay.log
```

### Log Rotation

```bash
# Install logrotate
sudo apt install logrotate

# Configure
sudo vim /etc/logrotate.d/tomcat
```

```
/opt/tomcat/logs/catalina.out {
    daily
    rotate 14
    compress
    missingok
    notifempty
    create 640 tomcat tomcat
    sharedscripts
    postrotate
        /opt/tomcat/bin/catalina.sh stop
        /opt/tomcat/bin/catalina.sh start
    endscript
}
```

### System Monitoring

```bash
# Install monitoring tools
sudo apt install htop nethogs iotop

# Monitor Java processes
jps -lv

# Monitor Tomcat threads
ps -eLf | grep tomcat | wc -l
```

## Backup Strategy

### Database Backups

**Automated daily backup:**

```bash
# Create backup script
sudo vim /usr/local/bin/backup-ebay-db.sh
```

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/ebay"
mkdir -p $BACKUP_DIR

mysqldump -u ebay_app -p'password' ebay | gzip > $BACKUP_DIR/ebay_$DATE.sql.gz

# Keep only last 7 days
find $BACKUP_DIR -name "ebay_*.sql.gz" -mtime +7 -delete
```

**Schedule with cron:**
```bash
sudo chmod +x /usr/local/bin/backup-ebay-db.sh
sudo crontab -e

# Add line:
0 2 * * * /usr/local/bin/backup-ebay-db.sh
```

### Application Backups

```bash
# Backup WAR file and configuration
tar -czf ebay-app-$(date +%Y%m%d).tar.gz \
    $CATALINA_HOME/webapps/ebay-1.0-SNAPSHOT/ \
    $CATALINA_HOME/conf/server.xml
```

## Troubleshooting

### Application Won't Start

**Check logs:**
```bash
tail -100 $CATALINA_HOME/logs/catalina.out
```

**Common issues:**
- Database connection failed (check credentials)
- Port already in use (check with `netstat -tulpn | grep 8080`)
- Insufficient memory (increase JVM heap)

### Database Connection Errors

```bash
# Test connection
mysql -u ebay_app -p -h localhost ebay

# Check MySQL is running
sudo systemctl status mysql
```

### Out of Memory Errors

Increase JVM heap in `setenv.sh`:
```bash
export CATALINA_OPTS="$CATALINA_OPTS -Xmx4096m"
```

## Update Procedure

```bash
# 1. Backup database
mysqldump -u ebay_app -p ebay > backup_before_update.sql

# 2. Stop Tomcat
sudo systemctl stop tomcat

# 3. Backup current WAR
cp $CATALINA_HOME/webapps/ebay-1.0-SNAPSHOT.war ~/backup/

# 4. Deploy new WAR
sudo cp target/ebay-1.0-SNAPSHOT.war $CATALINA_HOME/webapps/

# 5. Start Tomcat
sudo systemctl start tomcat

# 6. Monitor logs
tail -f $CATALINA_HOME/logs/catalina.out
```

## Related Documentation

- [Getting Started](getting-started.md) - Local development setup
- [Database Setup](database/setup.md) - Database configuration
- [Security Guide](security.md) - Security best practices

