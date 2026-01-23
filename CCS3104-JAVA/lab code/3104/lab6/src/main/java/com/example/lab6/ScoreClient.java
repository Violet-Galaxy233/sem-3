package com.example.lab6;

import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.GridPane;
import javafx.stage.Stage;

import java.rmi.Naming;

public class ScoreClient extends Application {

    private ScoreService scoreService;

    @Override
    public void start(Stage primaryStage) {
        // --- UI 布局设置 ---
        GridPane grid = new GridPane();
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));

        Label nameLabel = new Label("Student Name:");
        TextField nameField = new TextField();
        Button btnGetScore = new Button("Get Score");
        Label resultLabel = new Label("Score will appear here");

        grid.add(nameLabel, 0, 0);
        grid.add(nameField, 1, 0);
        grid.add(btnGetScore, 1, 1);
        grid.add(resultLabel, 1, 2);

        // --- 按钮点击事件 ---
        btnGetScore.setOnAction(e -> {
            String name = nameField.getText();
            try {
                // 连接 RMI 服务器
                if (scoreService == null) {
                    scoreService = (ScoreService) Naming.lookup("rmi://localhost/ScoreService");
                }

                // 调用远程方法
                double score = scoreService.getScore(name);

                // 处理结果
                if (score == -1.0) {
                    resultLabel.setText("Student not found.");
                } else if (score == -2.0) {
                    resultLabel.setText("No permission to view score.");
                } else {
                    resultLabel.setText("Score: " + score);
                }

            } catch (Exception ex) {
                resultLabel.setText("Error: " + ex.getMessage());
                ex.printStackTrace();
            }
        });

        Scene scene = new Scene(grid, 350, 200);
        primaryStage.setTitle("Student Score Client");
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}