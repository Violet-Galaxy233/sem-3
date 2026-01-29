package com.example.lab5;

import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.GridPane;
import javafx.stage.Stage;

import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

public class CircleClientFX extends Application {

    private CircleService service;

    @Override
    public void start(Stage stage) {
        // ===== UI =====
        Label title = new Label("RMI Circle Area Calculator");
        Label radiusLabel = new Label("Radius:");
        TextField radiusField = new TextField();
        radiusField.setPromptText("e.g. 2.5");

        Button calcBtn = new Button("Calculate Area");
        Label resultLabel = new Label("Area: -");
        Label statusLabel = new Label("Status: Not connected");

        GridPane root = new GridPane();
        root.setPadding(new Insets(16));
        root.setHgap(10);
        root.setVgap(10);

        root.add(title, 0, 0, 2, 1);
        root.add(radiusLabel, 0, 1);
        root.add(radiusField, 1, 1);
        root.add(calcBtn, 1, 2);
        root.add(resultLabel, 0, 3, 2, 1);
        root.add(statusLabel, 0, 4, 2, 1);

        // ===== RMI connect =====
        // 课上一般默认 localhost:1099；你也可以改成读取 args
        String host = "localhost";
        int port = 1099;

        try {
            Registry registry = LocateRegistry.getRegistry(host, port);
            service = (CircleService) registry.lookup("CircleService");
            statusLabel.setText("Status: Connected to " + host + ":" + port);
        } catch (Exception e) {
            statusLabel.setText("Status: Connect failed (" + e.getClass().getSimpleName() + ")");
            // 不直接退出，让你看到窗口和错误状态
        }

        // ===== Button action =====
        calcBtn.setOnAction(evt -> {
            if (service == null) {
                statusLabel.setText("Status: Not connected. Start Registry + Server first.");
                return;
            }

            String input = radiusField.getText().trim();
            if (input.isEmpty()) {
                statusLabel.setText("Status: Please enter a radius.");
                return;
            }

            try {
                double r = Double.parseDouble(input);
                double area = service.area(r);
                resultLabel.setText("Area: " + area);
                statusLabel.setText("Status: OK");
            } catch (NumberFormatException nfe) {
                statusLabel.setText("Status: Invalid number.");
            } catch (Exception ex) {
                statusLabel.setText("Status: RMI error (" + ex.getClass().getSimpleName() + ")");
            }
        });

        // ===== Stage =====
        stage.setTitle("RMI Lab - JavaFX Client");
        stage.setScene(new Scene(root, 420, 220));
        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}