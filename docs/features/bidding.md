# Bidding Engine

The bidding engine allows users to place bids on auction listings with automatic highest bid tracking and bid history.

## How Bidding Works

### Placing a Bid

**Endpoint:** `POST /bids/place`

**Requirements:**
- User must be authenticated
- Product must be active (not closed)
- Bid amount must exceed current highest bid
- User cannot bid on their own products

**Request:**
```java
POST /bids/place
Content-Type: application/x-www-form-urlencoded

productId=123&amount=50.00
```

**Process:**
1. Validate user is authenticated
2. Check product exists and is active
3. Query current highest bid
4. Validate new bid amount > current highest
5. Insert bid into database
6. Update product's current price
7. Return success/failure response

### Bid Validation Rules

```java
// Minimum increment (planned)
BigDecimal minIncrement = currentHighestBid.multiply(new BigDecimal("0.05")); // 5%
BigDecimal minimumBid = currentHighestBid.add(minIncrement);

if (newBid.compareTo(minimumBid) < 0) {
    throw new ValidationException("Bid must be at least " + minimumBid);
}
```

**Current Rules:**
- Bid must be higher than current price
- No maximum bid limit

**Planned Rules:**
- Minimum increment (5% or $1, whichever is greater)
- Reserve price (hidden minimum)
- Maximum bid limits per user
- Bid retraction (within time window)

## Bid History

### Viewing Bid History

**Endpoint:** `GET /products/{id}/bids`

**Display:**
- List of all bids for a product
- Bidder username (or anonymous)
- Bid amount
- Timestamp
- Status (winning, outbid)

**Example:**
```
Bid History for "iPhone 15 Pro"

1. john_doe      $550.00    2 minutes ago    [Winning Bid]
2. jane_smith    $525.00    15 minutes ago   [Outbid]
3. mike_jones    $500.00    1 hour ago       [Outbid]
```

### Privacy Options (Planned)

- **Public** - Show all bidder usernames
- **Anonymous** - Show as "Bidder 1", "Bidder 2"
- **Masked** - Show as "j***e" (partial username)

## Highest Bid Tracking

### Current Implementation

**Real-time Updates:**
- Product's `current_price` field updated on each bid
- Query for highest bid:
```sql
SELECT MAX(amount) as highest_bid, 
       user_id as highest_bidder
FROM bids 
WHERE product_id = ? 
GROUP BY product_id;
```

**Caching (Planned):**
- Store highest bid in `products` table
- Update via database trigger or application logic
- Reduce query overhead

## Concurrent Bidding

### Current State: Race Condition Risk

**Problem:**
```
Time    User A              User B
----    ------              ------
T1      Read highest: $100
T2                          Read highest: $100
T3      Bid $105            
T4                          Bid $105 ❌ (should fail)
T5      SUCCESS             SUCCESS (WRONG!)
```

### Planned Solution: Transaction Isolation

**Approach 1: Optimistic Locking**
```java
@Transactional(isolation = Isolation.REPEATABLE_READ)
public void placeBid(int productId, BigDecimal amount, int userId) {
    // Read current highest within transaction
    BigDecimal currentHighest = bidDao.getHighestBid(productId);
    
    if (amount.compareTo(currentHighest) <= 0) {
        throw new BidTooLowException();
    }
    
    // Insert bid
    bidDao.insert(new Bid(productId, userId, amount));
    
    // Commit transaction
}
```

**Approach 2: Database Constraint**
```sql
-- Add unique constraint on (product_id, amount)
-- to prevent duplicate bid amounts
ALTER TABLE bids ADD CONSTRAINT unique_product_bid 
    UNIQUE(product_id, amount);
```

**Approach 3: Pessimistic Locking**
```sql
SELECT * FROM products WHERE id = ? FOR UPDATE;
-- Lock the product row until transaction completes
```

## Auction Lifecycle

### Auction States

```
SCHEDULED → ACTIVE → CLOSING → CLOSED
```

**States:**
1. **SCHEDULED** (Planned) - Future start time
2. **ACTIVE** - Currently accepting bids
3. **CLOSING** (Planned) - Final minutes (anti-sniping)
4. **CLOSED** - Auction ended

### Auto-Close Mechanism (Planned)

**Scheduled Task:**
```java
@Scheduled(fixedRate = 60000) // Every 1 minute
public void closeExpiredAuctions() {
    List<Product> expired = productDao.findExpiredAuctions();
    
    for (Product product : expired) {
        Bid winningBid = bidDao.getHighestBid(product.getId());
        
        // Mark auction as closed
        product.setStatus("CLOSED");
        productDao.update(product);
        
        // Notify winner
        notificationService.notifyWinner(winningBid.getUserId(), product);
        
        // Log result
        auditService.logAuctionClosed(product, winningBid);
    }
}
```

### Anti-Sniping (Planned)

**Extend Auction:**
- If bid placed in final 2 minutes
- Extend end time by 2 more minutes
- Prevents last-second bid sniping

```java
if (product.getEndTime().minusMinutes(2).isBefore(LocalDateTime.now())) {
    product.setEndTime(LocalDateTime.now().plusMinutes(2));
    productDao.update(product);
}
```

## Reserve Price (Planned)

### Hidden Minimum

**Concept:**
- Seller sets secret minimum price
- Auction only succeeds if highest bid meets reserve
- Bidders see "Reserve not met" status

**Implementation:**
```sql
ALTER TABLE products ADD COLUMN reserve_price DECIMAL(10,2);
```

```java
if (highestBid.getAmount().compareTo(product.getReservePrice()) < 0) {
    product.setStatus("CLOSED_RESERVE_NOT_MET");
} else {
    product.setStatus("CLOSED_SUCCESS");
}
```

## Proxy Bidding (Planned)

### Autobid Mechanism

**Concept:**
- User sets maximum bid
- System automatically bids on their behalf
- Bids minimum necessary to stay ahead

**Example:**
```
1. Alice sets max bid: $200
2. Current price: $100
3. Bob bids: $110
4. System auto-bids for Alice: $115 (min increment)
5. Current price now: $115 (Alice winning)
6. Bob bids: $150
7. System auto-bids for Alice: $155
8. Bob bids: $210
9. Alice is outbid (max reached)
```

**Database Schema:**
```sql
CREATE TABLE proxy_bids (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    max_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## Bid Increment Rules

### Dynamic Increments (Planned)

| Current Price Range | Minimum Increment |
|---------------------|-------------------|
| $0 - $50            | $1                |
| $50 - $200          | $5                |
| $200 - $500         | $10               |
| $500 - $1,000       | $25               |
| $1,000+             | $50               |

**Implementation:**
```java
public BigDecimal getMinimumIncrement(BigDecimal currentPrice) {
    if (currentPrice.compareTo(new BigDecimal("50")) < 0) {
        return new BigDecimal("1");
    } else if (currentPrice.compareTo(new BigDecimal("200")) < 0) {
        return new BigDecimal("5");
    }
    // ... additional ranges
}
```

## Database Schema

### Bids Table

```sql
CREATE TABLE bids (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_product_amount (product_id, amount DESC),
    INDEX idx_user_bids (user_id, created_at DESC)
);
```

**Indexes:**
- `idx_product_amount` - Fast highest bid queries
- `idx_user_bids` - User bid history

## API Reference

### BidServlet

| Endpoint               | Method | Auth Required | Description           |
|------------------------|--------|---------------|-----------------------|
| `/bids/place`          | POST   | Yes (USER)    | Place a bid           |
| `/products/{id}/bids`  | GET    | No            | View bid history      |
| `/bids/my-bids`        | GET    | Yes (USER)    | View own bid history  |

### Request/Response Examples

**Place Bid:**
```json
Request:
POST /bids/place
{
    "productId": 123,
    "amount": 150.00
}

Success Response:
{
    "success": true,
    "message": "Bid placed successfully",
    "newHighestBid": 150.00,
    "bidCount": 15
}

Error Response:
{
    "success": false,
    "error": "Bid must be higher than current price of $140.00"
}
```

## Notifications (Planned)

### Outbid Alerts

**Channels:**
- Email notification
- In-app notification
- SMS (optional)

**Message:**
```
You've been outbid!

Product: iPhone 15 Pro
Your bid: $525.00
New highest bid: $550.00

Place a higher bid to win!
[View Auction]
```

### Winning Notification

**On Auction Close:**
```
Congratulations! You won the auction!

Product: iPhone 15 Pro
Winning bid: $550.00
Seller: tech_store

Next steps:
1. Complete payment
2. Arrange shipping
3. Leave feedback

[View Details]
```

## Best Practices

1. **Always validate bids** - Check highest bid within transaction
2. **Use database transactions** - Ensure bid consistency
3. **Log all bids** - Audit trail for disputes
4. **Rate limit bidding** - Prevent spam/manipulation
5. **Notify on outbid** - Keep users engaged
6. **Handle edge cases** - Tie bids, rapid succession
7. **Test concurrency** - Simulate multiple bidders

## Security Considerations

### Bid Manipulation Prevention

**Shill Bidding Detection (Planned):**
- Flag accounts with suspicious patterns
- Same IP bidding on same auction
- New accounts immediately bidding high

**Rate Limiting:**
- Max 10 bids per minute per user
- Max 100 bids per auction per user

**Validation:**
- Cannot bid on own products
- Cannot bid after auction close
- Cannot place negative or zero bids

## Performance Optimization

### Database Queries

**Cache Highest Bid:**
```sql
-- Denormalize highest bid into products table
ALTER TABLE products ADD COLUMN highest_bid DECIMAL(10,2);
ALTER TABLE products ADD COLUMN bid_count INT DEFAULT 0;
```

**Update via Trigger:**
```sql
CREATE TRIGGER update_highest_bid
AFTER INSERT ON bids
FOR EACH ROW
UPDATE products 
SET highest_bid = NEW.amount, 
    bid_count = bid_count + 1
WHERE id = NEW.product_id;
```

## Code Examples

### Place Bid

```java
@WebServlet("/bids/place")
public class BidServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        User user = (User) request.getSession().getAttribute("user");
        int productId = Integer.parseInt(request.getParameter("productId"));
        BigDecimal amount = new BigDecimal(request.getParameter("amount"));
        
        try {
            bidDao.placeBid(productId, user.getId(), amount);
            response.getWriter().write("{\"success\": true}");
        } catch (BidTooLowException e) {
            response.setStatus(400);
            response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }
}
```

### Get Bid History

```java
List<Bid> bids = bidDao.findByProduct(productId);
request.setAttribute("bids", bids);
request.getRequestDispatcher("/WEB-INF/jsp/bid-history.jsp").forward(request, response);
```

## Related Documentation

- [Products & Listings](products.md) - Product management
- [Database Schema](../database/schema.md) - Bids table structure
- [Security Guide](../security.md) - Bid manipulation prevention
