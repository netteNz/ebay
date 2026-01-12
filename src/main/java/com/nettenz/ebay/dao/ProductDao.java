package com.nettenz.ebay.dao;

import com.nettenz.ebay.db.Db;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDao {

    public void create(Long sellerId, Long departmentId, String name, String description, String imageUrl, BigDecimal startingBid) {
        final String sql = """
            INSERT INTO products (seller_user_id, department_id, name, description, image_url, starting_bid)
            VALUES (?, ?, ?, ?, ?, ?)
        """;

        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            
            ps.setLong(1, sellerId);
            if (departmentId != null) {
                ps.setLong(2, departmentId);
            } else {
                ps.setNull(2, Types.BIGINT);
            }
            ps.setString(3, name);
            ps.setString(4, description);
            ps.setString(5, imageUrl);
            ps.setBigDecimal(6, startingBid);
            
            ps.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("DB error in ProductDao.create", e);
        }
    }

    public List<ProductDto> findAll() {
        List<ProductDto> list = new ArrayList<>();
        final String sql = """
            SELECT p.product_id, p.seller_user_id, p.name, p.description, p.image_url, p.starting_bid, p.created_at,
                   u.username as seller_name,
                   COALESCE(MAX(b.amount), p.starting_bid) as current_price,
                   COUNT(b.bid_id) as bid_count
            FROM products p
            JOIN users u ON p.seller_user_id = u.user_id
            LEFT JOIN bids b ON p.product_id = b.product_id
            GROUP BY p.product_id, p.seller_user_id, p.name, p.description, p.image_url, p.starting_bid, p.created_at, u.username
            ORDER BY p.created_at DESC
        """;

        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapToProductDto(rs));
            }

        } catch (SQLException e) {
            throw new RuntimeException("DB error in findAll products", e);
        }
        return list;
    }

    public ProductDto findById(Long productId) {
        final String sql = """
            SELECT p.product_id, p.seller_user_id, p.name, p.description, p.image_url, p.starting_bid, p.created_at,
                   u.username as seller_name,
                   COALESCE(MAX(b.amount), p.starting_bid) as current_price,
                   COUNT(b.bid_id) as bid_count
            FROM products p
            JOIN users u ON p.seller_user_id = u.user_id
            LEFT JOIN bids b ON p.product_id = b.product_id
            WHERE p.product_id = ?
            GROUP BY p.product_id, p.seller_user_id, p.name, p.description, p.image_url, p.starting_bid, p.created_at, u.username
        """;

        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapToProductDto(rs);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("DB error in findById product", e);
        }
        return null;
    }

    private ProductDto mapToProductDto(ResultSet rs) throws SQLException {
        return new ProductDto(
                rs.getLong("product_id"),
                rs.getLong("seller_user_id"),
                rs.getString("name"),
                rs.getString("description"),
                rs.getString("image_url"),
                rs.getBigDecimal("starting_bid"),
                rs.getBigDecimal("current_price"),
                rs.getString("seller_name"),
                rs.getInt("bid_count"),
                rs.getTimestamp("created_at")
        );
    }

    public record ProductDto(
            Long id,
            Long sellerId,
            String name,
            String description,
            String imageUrl,
            BigDecimal startingBid,
            BigDecimal currentPrice,
            String sellerName,
            int bidCount,
            Timestamp createdAt
    ) {}
}
