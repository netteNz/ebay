# Getting Started

This guide will help you set up and run the eBay Auction Platform on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Java 21** or higher
- **Maven 3.8+** for building the project
- **MySQL 8.x** for the database
- **Apache Tomcat 10.1+** for running the application

### Verify Installation

```bash
java -version    # Should show Java 21+
mvn -version     # Should show Maven 3.8+
mysql --version  # Should show MySQL 8.x
```

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/nettenz/ebay.git
cd ebay
```

### 2. Set Up the Database

Start MySQL and create the database:

```bash
mysql -u root -p
```

Then run the schema script:

```sql
SOURCE db/schema.sql;
```

This will create:
- Database: `ebay_db`
- Tables: `users`, `products`, `departments`, `bids`
- Sample admin user (username: `admin`, password: `admin123`)

For more details, see [Database Setup](database/setup.md).

### 3. Build the Application

Build the WAR file using Maven:

```bash
mvn clean package
```

The WAR file will be generated at: `target/ebay-1.0-SNAPSHOT.war`

### 4. Deploy to Tomcat

Copy the WAR file to your Tomcat webapps directory:

```bash
cp target/ebay-1.0-SNAPSHOT.war $CATALINA_HOME/webapps/
```

Start Tomcat:

```bash
$CATALINA_HOME/bin/catalina.sh run
```

### 5. Access the Application

Open your browser and navigate to:

```
http://localhost:8080/ebay-1.0-SNAPSHOT/
```

## Default Credentials

### Admin Account
- **Username:** `admin`
- **Password:** `admin123`

!!! warning "Security Note"
    Change the default admin password immediately in production environments.

## Next Steps

- [Explore the Architecture](architecture.md) - Understand the system design
- [Learn about Features](features/authentication.md) - Deep dive into functionality
- [API Reference](api/servlets.md) - Servlet endpoints documentation
- [Security Best Practices](security.md) - Production security guidelines

## Troubleshooting

### Common Issues

**Port Already in Use**
```bash
# Check what's using port 8080
lsof -i :8080
```

**Database Connection Refused**
- Verify MySQL is running: `sudo systemctl status mysql`
- Check credentials in database connection configuration

**Build Failures**
```bash
# Clean Maven cache and rebuild
mvn clean install -U
```

## Development Mode

For development with hot reload, consider using:

```bash
mvn tomcat7:run
```

Or configure your IDE (IntelliJ IDEA, Eclipse) to deploy to Tomcat automatically.
