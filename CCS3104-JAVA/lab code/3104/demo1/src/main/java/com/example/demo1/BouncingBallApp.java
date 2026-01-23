package com.example.demo1;
import javafx.animation.AnimationTimer;
import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.layout.Pane;
import javafx.scene.paint.Color;
import javafx.scene.shape.Circle;
import javafx.stage.Stage;

public class BouncingBallApp extends Application {
    // 小球参数
    private double x, y;          // 位置
    private double vx = 220;      // 水平速度（像素/秒）
    private double vy = 180;      // 垂直速度（像素/秒）
    private final double r = 16;  // 半径

    @Override
    public void start(Stage stage) {
        Pane root = new Pane();
        Scene scene = new Scene(root, 640, 400, Color.WHITE);

        Circle ball = new Circle(r, Color.DODGERBLUE);
        ball.setStroke(Color.BLACK);
        ball.setStrokeWidth(1.2);

        // 初始位置放中间
        x = scene.getWidth() / 2.0;
        y = scene.getHeight() / 2.0;
        ball.setCenterX(x);
        ball.setCenterY(y);

        root.getChildren().add(ball);

        stage.setTitle("JavaFX Bouncing Ball (Resizable)");
        stage.setScene(scene);
        stage.show();

        // 使用 AnimationTimer 实现帧率无关的更新（以纳秒计时）
        AnimationTimer timer = new AnimationTimer() {
            private long lastNs = -1;

            @Override
            public void handle(long now) {
                if (lastNs < 0) {
                    lastNs = now;
                    return;
                }

                double dt = (now - lastNs) / 1_000_000_000.0; // 纳秒 -> 秒
                lastNs = now;

                // 更新位置
                x += vx * dt;
                y += vy * dt;

                // 获取当前容器宽高（窗口可变）
                double width = root.getWidth();
                double height = root.getHeight();

                // 边界可能暂时为0（窗口刚显示/极端缩放），做个保护
                if (width <= 0 || height <= 0) return;

                // 碰撞检测 + 响应（带回夹）
                // 左右
                if (x - r < 0) {
                    x = r;
                    vx = Math.abs(vx);        // 向右
                } else if (x + r > width) {
                    x = width - r;
                    vx = -Math.abs(vx);       // 向左
                }

                // 上下
                if (y - r < 0) {
                    y = r;
                    vy = Math.abs(vy);        // 向下
                } else if (y + r > height) {
                    y = height - r;
                    vy = -Math.abs(vy);       // 向上
                }

                // 极端情况：窗口被缩得比直径还小，强制放在中心避免“抖/消失”
                if (width < 2 * r) x = width / 2.0;
                if (height < 2 * r) y = height / 2.0;

                // 应用到图形
                ball.setCenterX(x);
                ball.setCenterY(y);
            }
        };
        timer.start();
    }

    public static void main(String[] args) {
        launch(args);
    }
}