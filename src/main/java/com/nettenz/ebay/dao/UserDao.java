package com.nettenz.ebay.dao;

import com.nettenz.ebay.db.Db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDao {

    public UserRecord findByUsername(String username) {
        final String sql = """
          SELECT user_id, username, password_hash, role
          FROM users
          WHERE username = ?
        """;

        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                return new UserRecord(
                        rs.getLong("user_id"),
                        rs.getString("username"),
                        rs.getString("password_hash"),
                        rs.getString("role")
                );
            }

        } catch (SQLException e) {
            throw new RuntimeException("DB error in findByUsername()", e);
        }
    }

    public record UserRecord(long userId, String username, String passwordHash, String role) {}
}
