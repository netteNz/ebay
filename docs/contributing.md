# Contributing to eBay Auction Platform

Thank you for considering contributing to this project! This guide will help you get started.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Respect differing opinions and experiences

## Getting Started

### Prerequisites

- Java 21
- Maven 3.8+
- MySQL 8.x
- Apache Tomcat 10.1+
- Git

### Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/ebay.git
cd ebay

# Add upstream remote
git remote add upstream https://github.com/nettenz/ebay.git
```

### Set Up Development Environment

```bash
# Create database
mysql -u root -p < db/schema.sql

# Build project
mvn clean install

# Run tests (when available)
mvn test

# Deploy to Tomcat for testing
cp target/ebay-1.0-SNAPSHOT.war $CATALINA_HOME/webapps/
```

## Development Workflow

### Branching Strategy

- `main` - Stable production code
- `develop` - Integration branch for features
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical production fixes

### Creating a Feature Branch

```bash
# Update your local repository
git checkout develop
git pull upstream develop

# Create feature branch
git checkout -b feature/your-feature-name

# Work on your feature
# ...

# Commit changes
git add .
git commit -m "Add feature: your feature description"

# Push to your fork
git push origin feature/your-feature-name
```

### Keeping Your Branch Updated

```bash
# Fetch latest changes from upstream
git fetch upstream

# Rebase your branch on latest develop
git rebase upstream/develop

# Force push to your fork (if already pushed)
git push origin feature/your-feature-name --force
```

## Coding Standards

### Java Style Guide

Follow standard Java conventions:

```java
// Class names: PascalCase
public class ProductService {}

// Method names: camelCase
public void createProduct() {}

// Constants: UPPER_SNAKE_CASE
private static final int MAX_UPLOAD_SIZE = 5242880;

// Variables: camelCase
int productId = 123;
```

### Code Formatting

- **Indentation:** 4 spaces (no tabs)
- **Line length:** Max 120 characters
- **Braces:** Opening brace on same line

```java
public class Example {
    public void method() {
        if (condition) {
            // code
        } else {
            // code
        }
    }
}
```

### Comments

**Do:**
- Document public APIs with Javadoc
- Explain complex logic
- Document WHY, not WHAT

```java
/**
 * Calculates the highest bid for a product using pessimistic locking
 * to prevent race conditions during concurrent bidding.
 *
 * @param productId the product to query
 * @return the highest bid amount, or null if no bids exist
 */
public BigDecimal getHighestBid(int productId) {
    // Acquire row lock to prevent concurrent modifications
    // ...
}
```

**Don't:**
```java
// Bad: obvious comment
int count = 0; // Initialize count to zero

// Good: explains non-obvious logic
int count = 0; // Offset by 1 because bidding starts at $1, not $0
```

### Package Structure

```
com.nettenz.ebay/
├── servlet/       # HTTP controllers
├── dao/           # Data access layer
├── model/         # Domain objects
├── filter/        # Servlet filters
├── util/          # Utility classes
└── db/            # Database connection
```

### Naming Conventions

**Servlets:**
- Suffix with `Servlet`
- Example: `LoginServlet`, `CreateProductServlet`

**DAOs:**
- Suffix with `Dao`
- Example: `UserDao`, `ProductDao`

**Models:**
- Simple noun
- Example: `User`, `Product`, `Bid`

**Filters:**
- Suffix with `Filter`
- Example: `AuthFilter`, `LoggingFilter`

## Testing Guidelines

### Unit Tests

Use JUnit 5 for unit tests:

```java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class ProductDaoTest {
    
    @Test
    void testCreateProduct() {
        Product product = new Product("Test Product", "Description", new BigDecimal("10.00"));
        productDao.create(product);
        
        assertNotNull(product.getId());
        assertEquals("Test Product", product.getName());
    }
    
    @Test
    void testFindById() {
        Product product = productDao.findById(1);
        assertNotNull(product);
    }
}
```

### Integration Tests

Test servlet interactions:

```java
@WebAppConfiguration
class LoginServletTest {
    
    @Test
    void testLoginSuccess() {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setParameter("username", "admin");
        request.setParameter("password", "admin123");
        
        MockHttpServletResponse response = new MockHttpServletResponse();
        
        servlet.doPost(request, response);
        
        assertEquals(302, response.getStatus());
    }
}
```

### Test Coverage

Aim for:
- Unit tests: 70%+ coverage
- Integration tests for critical paths
- Manual testing for UI/UX

### Running Tests

```bash
# Run all tests
mvn test

# Run specific test
mvn test -Dtest=ProductDaoTest

# Run with coverage report
mvn clean test jacoco:report
```

## Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] Self-review of code changes
- [ ] Comments added to complex logic
- [ ] Tests added/updated
- [ ] Tests pass locally
- [ ] Documentation updated (if needed)
- [ ] No merge conflicts with develop branch

### Creating a Pull Request

1. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR on GitHub:**
   - Go to original repository
   - Click "New Pull Request"
   - Select your fork and branch
   - Fill out PR template

3. **PR Title Format:**
   ```
   [Feature] Add proxy bidding system
   [Bugfix] Fix SQL injection in search
   [Docs] Update API documentation
   [Refactor] Improve DAO layer architecture
   ```

4. **PR Description:**
   ```markdown
   ## Changes
   - Added proxy bidding feature
   - Created ProxyBidDao for database operations
   - Updated BidServlet to handle proxy bids
   
   ## Testing
   - Added unit tests for ProxyBidDao
   - Manual testing with 5 concurrent bidders
   
   ## Screenshots (if UI changes)
   [Add screenshots here]
   
   ## Related Issues
   Closes #42
   ```

### Code Review

- Respond to feedback promptly
- Make requested changes
- Push updates to same branch
- Request re-review when ready

### Merging

- PR requires 1 approval
- All checks must pass
- No merge conflicts
- Maintainer will merge

## Issue Reporting

### Bug Reports

Use this template:

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '....'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
- OS: [e.g., Ubuntu 20.04]
- Java Version: [e.g., 21]
- Tomcat Version: [e.g., 10.1.5]
- MySQL Version: [e.g., 8.0.33]

**Additional context**
Any other context about the problem.
```

### Feature Requests

```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Other solutions or features you've considered.

**Additional context**
Any other context or screenshots.
```

### Security Vulnerabilities

**DO NOT** create public issues for security vulnerabilities.

Instead:
1. Email: security@nettenz.com (if configured)
2. Include:
   - Description of vulnerability
   - Steps to reproduce
   - Impact assessment
   - Suggested fix (if any)

## Areas for Contribution

### High Priority

- [ ] CSRF protection implementation
- [ ] XSS sanitization
- [ ] Rate limiting on auth endpoints
- [ ] Auction auto-close scheduler
- [ ] Proxy bidding system

### Medium Priority

- [ ] Email notifications
- [ ] User profile pages
- [ ] Product search/filtering
- [ ] Bid history improvements
- [ ] Admin audit logging

### Low Priority

- [ ] UI/UX improvements
- [ ] Performance optimizations
- [ ] Additional test coverage
- [ ] Documentation improvements
- [ ] Docker deployment

## Questions?

- **Email:** emanuel@nettenz.com
- **GitHub Issues:** For feature discussions
- **Pull Requests:** For code questions

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing! 🎉

