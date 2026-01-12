package com.nettenz.ebay.dao;

import com.nettenz.ebay.db.Db;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class BidDao {

    public void placeBid(Long productId, Long bidderId, BigDecimal amount) {
        final String sql = """
            INSERT INTO bids (product_id, bidder_user_id, amount)
            VALUES (?, ?, ?)
        """;

        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setLong(1, productId);
            ps.setLong(2, bidderId);
            ps.setBigDecimal(3, amount);
            ps.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("DB error in BidDao.placeBid", e);
        }
    }

    public Optional<BidDto> getHighestBid(Long productId) {
        final String sql = """
            SELECT b.bid_id, b.product_id, b.bidder_user_id, b.amount, b.created_at,
                   u.username as bidder_name
            FROM bids b
            JOIN users u ON b.bidder_user_id = u.user_id
            WHERE b.product_id = ?
            ORDER BY b.amount DESC
            LIMIT 1
        """;

        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapToBidDto(rs));
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("DB error in BidDao.getHighestBid", e);
        }
        return Optional.empty();
    }

    public List<BidDto> getBidHistory(Long productId) {
        List<BidDto> list = new ArrayList<>();
        final String sql = """
            SELECT b.bid_id, b.product_id, b.bidder_user_id, b.amount, b.created_at,
                   u.username as bidder_name
            FROM bids b
            JOIN users u ON b.bidder_user_id = u.user_id
            WHERE b.product_id = ?
            ORDER BY b.created_at DESC
            LIMIT 50
        """;

        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapToBidDto(rs));
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("DB error in BidDao.getBidHistory", e);
        }
        return list;
    }

    public int getBidCount(Long productId) {
        final String sql = "SELECT COUNT(*) FROM bids WHERE product_id = ?";

        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("DB error in BidDao.getBidCount", e);
        }
        return 0;
    }

    private BidDto mapToBidDto(ResultSet rs) throws SQLException {
        return new BidDto(
                rs.getLong("bid_id"),
                rs.getLong("product_id"),
                rs.getLong("bidder_user_id"),
                rs.getString("bidder_name"),
                rs.getBigDecimal("amount"),
                rs.getTimestamp("created_at")
        );
    }

    public record BidDto(
            Long id,
            Long productId,
            Long bidderId,
            String bidderName,
            BigDecimal amount,
            Timestamp createdAt
    ) {}
}
