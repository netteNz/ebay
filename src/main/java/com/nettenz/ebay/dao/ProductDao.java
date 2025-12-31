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
        // Simple join to get seller name.
        // Also could join department if needed, but keeping it simple.
        final String sql = """
            SELECT p.product_id, p.name, p.description, p.image_url, p.starting_bid, p.created_at,
                   u.username as seller_name
            FROM products p
            JOIN users u ON p.seller_user_id = u.user_id
            ORDER BY p.created_at DESC
        """;

        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new ProductDto(
                        rs.getLong("product_id"),
                        rs.getString("name"),
                        rs.getString("description"),
                        rs.getString("image_url"),
                        rs.getBigDecimal("starting_bid"),
                        rs.getString("seller_name"),
                        rs.getTimestamp("created_at")
                ));
            }

        } catch (SQLException e) {
            throw new RuntimeException("DB error in findAll products", e);
        }
        return list;
    }

    public record ProductDto(
            Long id,
            String name,
            String description,
            String imageUrl,
            BigDecimal currentPrice, // currently just starting bid, logic to update with max bid later
            String sellerName,
            Timestamp createdAt
    ) {}
}
