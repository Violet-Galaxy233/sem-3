package com.example.demo1;
import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.StackPane;
import javafx.stage.Stage;

public class test1 extends Application {

    @Override
    public void start(Stage primaryStage) {
        // 1. 创建 BorderPane
        BorderPane pane = new BorderPane();

        // 2. 往五个区域放内容
        pane.setTop(new CustomPane("Top"));
        pane.setBottom(new CustomPane("Bottom"));
        pane.setLeft(new CustomPane("Left"));
        pane.setRight(new CustomPane("Right"));
        pane.setCenter(new CustomPane("Center"));

        // 3. 放 Scene & Stage
        Scene scene = new Scene(pane);
        primaryStage.setTitle("ShowBorderPane");
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}

// 自定义 Pane（每个区域显示一个 Label）
class CustomPane extends StackPane {
    public CustomPane(String title) {
        getChildren().add(new Label(title));
        setStyle("-fx-border-color: red");
        setPadding(new Insets(11.5, 12.5, 13.5, 14.5));
    }
}