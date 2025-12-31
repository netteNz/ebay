package com.nettenz.ebay.dao;

import com.nettenz.ebay.db.Db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class StatsDao {

    public DashboardStats getStats() {
        return new DashboardStats(
                count("users"),
                count("products"),
                count("bids")
        );
    }

    private long count(String tableName) {
        final String sql = "SELECT COUNT(*) FROM " + tableName;
        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getLong(1);
            }
            return 0;
        } catch (SQLException e) {
            throw new RuntimeException("DB error counting " + tableName, e);
        }
    }

    public record DashboardStats(long userCount, long productCount, long bidCount) {}
}
