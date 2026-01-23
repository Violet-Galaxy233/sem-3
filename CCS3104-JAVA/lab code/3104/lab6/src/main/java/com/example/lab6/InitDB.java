package com.example.lab6;

import java.sql.*;

public class InitDB {
    public static void main(String[] args) {
        String url = "jdbc:derby:javabook;create=true;user=scott;password=tiger";

        try (Connection conn = DriverManager.getConnection(url);
             Statement stmt = conn.createStatement()) {

            System.out.println("Database created/connected...");

            // 尝试删除旧表，避免重复创建报错
            try { stmt.execute("DROP TABLE Scores"); } catch (SQLException e) {}

            // 创建表
            stmt.execute("CREATE TABLE Scores (name varchar(20), score double, permission boolean)");
            System.out.println("Table created...");

            // 插入数据
            stmt.execute("INSERT INTO Scores values ('John', 90.5, true)");
            stmt.execute("INSERT INTO Scores values ('Michael', 100, true)");
            stmt.execute("INSERT INTO Scores values ('Michelle', 100, false)");

            System.out.println("Data inserted successfully.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}