# Products & Listings

The product management system allows users to create, browse, and manage auction listings with support for categories, images, and detailed descriptions.

## Product Creation

### Creating a New Listing

**Endpoint:** `POST /products/create`

**Required Fields:**
- `name` - Product title
- `description` - Detailed product description
- `departmentId` - Category/department ID
- `price` - Starting bid or buy-now price

**Optional Fields:**
- `image` - Upload file (multipart/form-data)
- `imageUrl` - External image URL (if no upload)

**Example Form:**
```html
<form action="/products/create" method="POST" enctype="multipart/form-data">
    <input type="text" name="name" placeholder="Product Name" required>
    <textarea name="description" placeholder="Description" required></textarea>
    <select name="departmentId" required>
        <option value="1">Electronics</option>
        <option value="2">Fashion</option>
    </select>
    <input type="number" name="price" placeholder="Starting Bid" required>
    <input type="file" name="image" accept="image/*">
    <button type="submit">Create Listing</button>
</form>
```

### Image Handling

**Upload Process:**
1. User selects image file (JPEG, PNG, GIF)
2. File uploaded via multipart form data
3. Server validates file type and size
4. File saved to `uploads/` directory with unique filename
5. Image path stored in database

**External URLs:**
- If no file uploaded, system accepts external image URL
- URL validated before storage
- Images loaded from external source when displayed

**File Storage:**
```
uploads/
  ├── product_123_image.jpg
  ├── product_124_image.png
  └── ...
```

**Image Serving:**
- Images served through `/images?id={productId}`
- `ImageServlet` handles file retrieval and streaming

## Product Browsing

### Listing All Products

**Endpoint:** `GET /products` or `GET /`

**Display:**
- Grid/list view of all active products
- Product name, image, current price
- Department/category badge
- Link to product details

**Filtering (Planned):**
- By department/category
- By price range
- By auction status (active, closed)
- Search by keyword

### Product Details

**Endpoint:** `GET /products/{id}`

**Information Displayed:**
- Product name and description
- Full-size image
- Current highest bid
- Bid history
- Auction end time
- Seller information

## Product Categories (Departments)

### Department Structure

Departments provide categorization for products:

```
Electronics
Fashion
Home & Garden
Sports
Collectibles
...
```

### Managing Departments

**Admin Only:**
- Create new departments
- Edit department names
- Delete unused departments

**Endpoint:** `/admin/departments`

## Product States

### Lifecycle

```
DRAFT → ACTIVE → CLOSED
```

**States:**
1. **DRAFT** (Planned) - Created but not yet published
2. **ACTIVE** - Live auction, accepting bids
3. **CLOSED** - Auction ended, no more bids

### Auction Timing (Planned)

**Fields:**
- `start_time` - When auction begins
- `end_time` - When auction closes
- `created_at` - Listing creation timestamp

**Auto-close (Planned):**
- Scheduled job checks `end_time`
- Automatically closes expired auctions
- Notifies winner

## Product Management

### My Listings

**Endpoint:** `GET /products/my-listings`

Users can view their own product listings:
- Edit product details
- View bid activity
- Close auction early (if allowed)
- Delete listing (if no bids)

### Admin Product Management

**Endpoint:** `GET /admin/products`

Admins can:
- View all products
- Edit any product
- Delete any product
- Feature products
- Manage reported listings

## Image Requirements

### Supported Formats
- JPEG (.jpg, .jpeg)
- PNG (.png)
- GIF (.gif)

### Size Limits
- Max file size: 5 MB (configurable)
- Recommended dimensions: 800x600 or larger
- Aspect ratio: Flexible (auto-scaled)

### Validation
```java
// Check file extension
String filename = file.getOriginalFilename();
if (!filename.matches(".*\\.(jpg|jpeg|png|gif)$")) {
    throw new ValidationException("Invalid image format");
}

// Check file size
if (file.getSize() > 5 * 1024 * 1024) {
    throw new ValidationException("File too large");
}
```

## Database Schema

### Products Table

```sql
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url VARCHAR(512),
    department_id INT,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### Departments Table

```sql
CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

See [Database Schema](../database/schema.md) for complete details.

## API Reference

### ProductServlet

| Endpoint            | Method | Auth Required | Description                |
|---------------------|--------|---------------|----------------------------|
| `/products`         | GET    | No            | List all products          |
| `/products/{id}`    | GET    | No            | View product details       |
| `/products/create`  | GET    | Yes (USER)    | Show create form           |
| `/products/create`  | POST   | Yes (USER)    | Create new product         |
| `/products/{id}/edit` | GET  | Yes (Owner)   | Show edit form             |
| `/products/{id}/edit` | POST | Yes (Owner)   | Update product             |

### ImageServlet

| Endpoint       | Method | Auth Required | Description         |
|----------------|--------|---------------|---------------------|
| `/images?id={productId}` | GET | No | Serve product image |

## Code Examples

### Create Product

```java
@WebServlet("/products/create")
@MultipartConfig
public class CreateProductServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        // Get form data
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        BigDecimal price = new BigDecimal(request.getParameter("price"));
        int departmentId = Integer.parseInt(request.getParameter("departmentId"));
        
        // Handle image upload
        Part filePart = request.getPart("image");
        String imageUrl = saveImage(filePart);
        
        // Create product via DAO
        Product product = new Product(name, description, price, imageUrl, departmentId);
        productDao.create(product);
        
        response.sendRedirect("/products");
    }
}
```

### Query Products by Department

```java
List<Product> products = productDao.findByDepartment(departmentId);
```

## Validation Rules

### Product Name
- Required
- 3-255 characters
- No special characters (except spaces, hyphens)

### Description
- Required
- 10-5000 characters
- HTML sanitization applied

### Price
- Required
- Positive decimal
- Max 2 decimal places
- Minimum: $0.01

### Department
- Required
- Must exist in `departments` table

## Best Practices

1. **Always validate input** on both client and server side
2. **Sanitize descriptions** to prevent XSS attacks
3. **Use transaction** when creating product with bids
4. **Optimize images** before upload to reduce storage
5. **Add product moderation** for marketplace quality
6. **Implement search indexing** for better performance

## Planned Features

- 🔄 **Draft Mode** - Save products before publishing
- 🔄 **Bulk Upload** - CSV import for multiple products
- 🔄 **Image Gallery** - Multiple images per product
- 🔄 **Product Variations** - Size, color options
- 🔄 **Shipping Info** - Weight, dimensions, costs
- 🔄 **Product Reviews** - Seller ratings
- 🔄 **Watchlist** - Save products to favorites

## Related Documentation

- [Bidding Engine](bidding.md) - How bids work on products
- [Admin Dashboard](admin.md) - Product management interface
- [Database Schema](../database/schema.md) - Table structures
