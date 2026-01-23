package com.example.demo1;


import javafx.animation.AnimationTimer;
import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.canvas.Canvas;
import javafx.scene.canvas.GraphicsContext;
import javafx.scene.image.WritableImage;
import javafx.scene.layout.StackPane;
import javafx.scene.paint.Color;
import javafx.stage.Stage;

public class PersistentRainbowTrail extends Application {
    // 状态
    private double x, y;          // 当前位置
    private double px, py;        // 上一帧位置
    private double vx = 220;      // px/s
    private double vy = 180;      // px/s
    private final double r = 14;  // 半径

    private double hue = 0.0;     // 0~360
    private double hueSpeed = 180;

    private Canvas trailLayer;    // 永久尾迹
    private Canvas ballLayer;     // 每帧清除只画球

    @Override
    public void start(Stage stage) {
        trailLayer = new Canvas(720, 420);
        ballLayer  = new Canvas(720, 420);

        StackPane root = new StackPane(trailLayer, ballLayer);
        Scene scene = new Scene(root, 720, 420, Color.WHITE);
        stage.setTitle("Persistent Rainbow Trail Bouncing Ball");
        stage.setScene(scene);
        stage.show();

        x = scene.getWidth() / 2.0;
        y = scene.getHeight() / 2.0;
        px = x; py = y;

        // 尾迹层白底
        var tgc = trailLayer.getGraphicsContext2D();
        tgc.setFill(Color.WHITE);
        tgc.fillRect(0, 0, trailLayer.getWidth(), trailLayer.getHeight());

        // 监听尺寸变化，保留 trail 内容
        root.widthProperty().addListener((o, ov, nv) -> resizeWithPreserve(nv.doubleValue(), root.getHeight()));
        root.heightProperty().addListener((o, ov, nv) -> resizeWithPreserve(root.getWidth(), nv.doubleValue()));

        AnimationTimer timer = new AnimationTimer() {
            private long lastNs = -1;

            @Override
            public void handle(long now) {
                if (lastNs < 0) { lastNs = now; return; }
                double dt = (now - lastNs) / 1_000_000_000.0;
                lastNs = now;

                double width  = trailLayer.getWidth();
                double height = trailLayer.getHeight();

                // 推进
                x += vx * dt;
                y += vy * dt;

                // 碰撞
                if (x - r < 0) { x = r; vx = Math.abs(vx); }
                else if (x + r > width) { x = width - r; vx = -Math.abs(vx); }
                if (y - r < 0) { y = r; vy = Math.abs(vy); }
                else if (y + r > height) { y = height - r; vy = -Math.abs(vy); }

                // 色相更新
                hue = (hue + hueSpeed * dt) % 360.0;
                Color c = Color.hsb(hue, 1.0, 1.0);

                // —— 永久尾迹：只补画新段，不清空 ——
                GraphicsContext tgc = trailLayer.getGraphicsContext2D();
                tgc.setStroke(c);
                tgc.setLineWidth(Math.max(1.5, r * 0.9));
                tgc.setLineCap(javafx.scene.shape.StrokeLineCap.ROUND);
                tgc.strokeLine(px, py, x, y);
                double dotR = r * 0.8;
                tgc.setFill(c);
                tgc.fillOval(x - dotR, y - dotR, dotR * 2, dotR * 2);

                // —— 前景球：清屏后再画当前球 ——
                GraphicsContext bgc = ballLayer.getGraphicsContext2D();
                bgc.clearRect(0, 0, width, height);
                bgc.setFill(Color.hsb(hue, 1.0, 1.0));
                bgc.fillOval(x - r, y - r, r * 2, r * 2);
                bgc.setStroke(Color.BLACK);
                bgc.setLineWidth(1.0);
                bgc.strokeOval(x - r, y - r, r * 2, r * 2);

                px = x; py = y;
            }
        };
        timer.start();
    }

    // 调整大小并保留 trail 的像素
    private void resizeWithPreserve(double newW, double newH) {
        if (newW <= 0 || newH <= 0) return;

        WritableImage snapshot = new WritableImage(
                (int) Math.max(1, trailLayer.getWidth()),
                (int) Math.max(1, trailLayer.getHeight())
        );
        trailLayer.snapshot(null, snapshot);

        trailLayer.setWidth(newW);
        trailLayer.setHeight(newH);
        ballLayer.setWidth(newW);
        ballLayer.setHeight(newH);

        GraphicsContext tgc = trailLayer.getGraphicsContext2D();
        tgc.setFill(Color.WHITE);
        tgc.fillRect(0, 0, newW, newH);
        // 这里直接左上角贴回；想要按新大小拉伸可以传目标宽高：
        tgc.drawImage(snapshot, 0, 0);
    }

    public static void main(String[] args) { launch(args); }
}