package com.example.lab3;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.layout.Pane;
import javafx.scene.paint.Color;
import javafx.scene.shape.Circle;
import javafx.scene.text.Text;
import javafx.stage.Stage;

public class lab3 extends Application {

    private int count = 0;
    private long startTime;

    private final int CIRCLE_RADIUS = 10;
    private final int TOTAL_CLICKS = 20;

    @Override
    public void start(Stage primaryStage) {

        Pane pane = new Pane();
        Scene scene = new Scene(pane, 400, 300);

        Circle circle = new Circle();
        circle.setRadius(CIRCLE_RADIUS);

        generateRandomCircle(circle, pane);

        pane.getChildren().add(circle);

        // record the time that first circle shows
        startTime = System.currentTimeMillis();

        circle.setOnMouseClicked(e -> {
            count++;

            if (count < TOTAL_CLICKS) {
                generateRandomCircle(circle, pane);
            } else {
                long endTime = System.currentTimeMillis();
                long timeSpent = endTime - startTime;

                pane.getChildren().clear();
                pane.getChildren().add(new Text(20, 50,
                        "Time spent is " + timeSpent + " milliseconds"));
            }
        });

        primaryStage.setTitle("LAB-3");
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    // random generate the location and the color
    private void generateRandomCircle(Circle circle, Pane pane) {
        double x = CIRCLE_RADIUS + Math.random() * (pane.getWidth()-20); //avoid the circle go out the pane
        double y = CIRCLE_RADIUS + Math.random() * (pane.getHeight()-20);

        circle.setCenterX(x);
        circle.setCenterY(y);
        // avoid it white
        circle.setFill(Color.color(Math.random() * 0.9, Math.random() * 0.9, Math.random() * 0.9));
    }

    public static void main(String[] args) {
        launch(args);
    }
}