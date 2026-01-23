package com.example.lab6;

import java.rmi.Naming;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.server.UnicastRemoteObject;
import java.sql.*;

public class ScoreServer extends UnicastRemoteObject implements ScoreService {

    // 数据库连接配置
    private static final String DB_URL = "jdbc:derby:javabook;user=scott;password=tiger";

    protected ScoreServer() throws RemoteException {
        super();
    }

    @Override
    public double getScore(String name) throws RemoteException {
        double score = -1.0; // 默认值，表示未找到或无权限
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DriverManager.getConnection(DB_URL);

            // 使用 PreparedStatement
            String sql = "SELECT score, permission FROM Scores WHERE name = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, name);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                boolean hasPermission = rs.getBoolean("permission");
                if (hasPermission) {
                    score = rs.getDouble("score");
                } else {
                    System.out.println("Found student but permission is false.");
                    score = -2.0; // 没有权限查看
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // 关闭资源
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return score;
    }

    public static void main(String[] args) {
        try {
            // 启动 RMI 注册表
            LocateRegistry.createRegistry(1099);

            ScoreServer server = new ScoreServer();
            Naming.rebind("ScoreService", server);

            System.out.println("Server is running and waiting for queries...");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}