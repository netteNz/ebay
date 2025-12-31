package com.nettenz.ebay.dao;

import com.nettenz.ebay.db.Db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AdminDao {

    public List<UserDto> findAllUsers() {
        List<UserDto> list = new ArrayList<>();
        String sql = "SELECT user_id, username, email, role, created_at FROM users ORDER BY created_at DESC";
        
        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(new UserDto(
                        rs.getLong("user_id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("role"),
                        rs.getTimestamp("created_at")
                ));
            }
        } catch (SQLException e) {
            throw new RuntimeException("DB Error fetching users", e);
        }
        return list;
    }

    public record UserDto(Long id, String username, String email, String role, java.sql.Timestamp joinedAt) {}
}
