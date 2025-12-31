package com.nettenz.ebay.dao;

import com.nettenz.ebay.db.Db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DepartmentDao {

    public void create(String name) {
        final String sql = "INSERT INTO departments (name) VALUES (?)";
        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("DB error creating department", e);
        }
    }

    public List<DepartmentRecord> findAll() {
        List<DepartmentRecord> list = new ArrayList<>();
        final String sql = "SELECT department_id, name FROM departments ORDER BY name";

        try (Connection c = Db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new DepartmentRecord(
                        rs.getLong("department_id"),
                        rs.getString("name")
                ));
            }
        } catch (SQLException e) {
            throw new RuntimeException("DB error in DepartmentDao.findAll", e);
        }
        return list;
    }

    public record DepartmentRecord(long id, String name) {}
}
