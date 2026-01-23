package com.example.demo1;
import javafx.application.Application;
import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.GridPane;
import javafx.geometry.Insets;

public class SpeedFineCalculator extends Application {

    @Override
    public void start(Stage primaryStage) {
        // 车辆类型（单选按钮）
        Label lblType = new Label("Vehicle Type:");
        RadioButton rbCar = new RadioButton("Car");
        RadioButton rbBike = new RadioButton("Bike");

        // 把两个按钮放进一个组，只能选一个
        ToggleGroup tgVehicle = new ToggleGroup();
        rbCar.setToggleGroup(tgVehicle);
        rbBike.setToggleGroup(tgVehicle);

        // 默认选中 Car
        rbCar.setSelected(true);

        //输入框
        Label lblSpeed = new Label("Vehicle Speed (km/h):");
        TextField tfSpeed = new TextField();

        Label lblLimit = new Label("Speed Limit (km/h):");
        TextField tfLimit = new TextField();

        //按钮与结果
        Button btCalc = new Button("Calculate");
        Label lblResult = new Label("Fine: RM 0.00");

        //  布局
        GridPane pane = new GridPane();
        pane.setPadding(new Insets(20));
        pane.setHgap(20);
        pane.setVgap(20);

        pane.add(lblType, 0, 0);
        pane.add(rbCar, 1, 0);
        pane.add(rbBike, 2, 0);
        pane.add(lblSpeed, 0, 1);
        pane.add(tfSpeed, 1, 1);
        pane.add(lblLimit, 0, 2);
        pane.add(tfLimit, 1, 2);
        pane.add(btCalc, 0, 3);
        pane.add(lblResult, 1, 3);

        // 按钮事件
        btCalc.setOnAction(e -> {
            try {
                double speed = Double.parseDouble(tfSpeed.getText());
                double limit = Double.parseDouble(tfLimit.getText());
                double fine = 0;

                if (speed > limit) {
                    if (rbCar.isSelected())
                        fine = 0.5 * Math.pow(speed - limit, 2);
                    else if (rbBike.isSelected())
                        fine = 30 + (speed - limit);
                }

                lblResult.setText(String.format("Fine: RM %.2f", fine));
            } catch (NumberFormatException ex) {
                lblResult.setText("Please enter valid numbers!");
            }
        });

        // 场景与显示
        Scene scene = new Scene(pane, 450, 200);
        primaryStage.setTitle("Speed Fine Calculator");
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}