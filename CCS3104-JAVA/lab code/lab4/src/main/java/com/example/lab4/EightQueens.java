package com.example.lab4;

import javafx.application.Application;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

import java.util.Arrays;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

public class EightQueens extends Application {
    public static final int SIZE = 8;

    // PPT Chapter 4: Blocking Queues [cite: 410]
    // 这是一个线程安全的队列，8个生产者线程同时往里放数据，UI线程从中取数据
    private BlockingQueue<int[]> solutionQueue = new LinkedBlockingQueue<>();

    // 当前显示在棋盘上的解
    private int[] currentQueens = new int[SIZE];

    // 计数器
    private int solutionCount = 0;

    // UI 组件
    private Label[][] labels = new Label[SIZE][SIZE];
    private Image queenImage;
    private Label infoLabel;

    @Override
    public void start(Stage primaryStage) {
        // 初始化数组
        Arrays.fill(currentQueens, -1);

        // ============================================================
        // 核心修改：启动 8 个线程并行计算
        // PPT Chapter 4: Creating Tasks and Threads [cite: 325, 326]
        // ============================================================
        for (int i = 0; i < SIZE; i++) {
            final int firstRowCol = i; // 这一列由当前线程负责

            Runnable task = new Runnable() {
                @Override
                public void run() {
                    // 每个线程拥有自己独立的棋盘数组，互不冲突
                    int[] localQueens = new int[SIZE];
                    Arrays.fill(localQueens, -1);

                    // 固定第一行的位置：(0, i)
                    localQueens[0] = firstRowCol;

                    // 从第二行 (row=1) 开始递归搜索
                    placeQueen(localQueens, 1);

                    System.out.println("Thread for column " + firstRowCol + " finished.");
                }
            };

            // 启动线程
            Thread thread = new Thread(task);
            thread.setDaemon(true); // 设为守护线程
            thread.setName("Thread-Column-" + i); // 方便调试观察
            thread.start();
        }
        // ============================================================

        // 2. 构建 UI (和之前保持一致)
        GridPane chessBoard = new GridPane();
        chessBoard.setAlignment(Pos.CENTER);

        for (int i = 0; i < SIZE; i++) {
            for (int j = 0; j < SIZE; j++) {
                labels[i][j] = new Label();
                labels[i][j].setStyle("-fx-border-color: black; -fx-background-color: white;");
                labels[i][j].setPrefSize(55, 55);
                chessBoard.add(labels[i][j], j, i);
            }
        }

        try {
            // 请修改为你本地的图片路径
            queenImage = new Image("file:/Users/y/Desktop/queen.jpg");
        } catch (Exception e) {
            System.out.println("Image load error: " + e.getMessage());
        }

        Button nextButton = new Button("Next Solution");
        infoLabel = new Label("8 Threads running... Click Next to get solution");

        // 3. 按钮事件 (Consumer)
        nextButton.setOnAction(e -> {
            try {
                // 从队列获取一个解
                int[] nextSolution = solutionQueue.poll();

                if (nextSolution != null) {
                    currentQueens = nextSolution;
                    solutionCount++;
                    updateBoard();
                    // 显示当前解是由哪个线程计算出来的（通过第一行的位置判断）
                    int threadIndex = currentQueens[0];
                    infoLabel.setText("Solution #" + solutionCount + " (Found by Thread-" + threadIndex + ")");
                } else {
                    infoLabel.setText("Queue empty (Wait or Finished)");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        });

        HBox controlBar = new HBox(10);
        controlBar.setAlignment(Pos.CENTER);
        controlBar.getChildren().addAll(nextButton, infoLabel);

        VBox root = new VBox(10);
        root.setAlignment(Pos.CENTER);
        root.getChildren().addAll(chessBoard, controlBar);

        Scene scene = new Scene(root, 55 * SIZE, 55 * SIZE + 60);
        primaryStage.setTitle("EightQueens - 8 Parallel Threads");
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    private void updateBoard() {
        for (int i = 0; i < SIZE; i++) {
            for (int j = 0; j < SIZE; j++) {
                labels[i][j].setGraphic(null);
            }
        }
        for (int i = 0; i < SIZE; i++) {
            int col = currentQueens[i];
            if (col >= 0 && col < SIZE && queenImage != null) {
                ImageView iv = new ImageView(queenImage);
                iv.setFitWidth(50);
                iv.setFitHeight(50);
                labels[i][col].setGraphic(iv);
            }
        }
    }

    // ================== 递归回溯算法 ==================

    /**
     * 在第 row 行放皇后
     * 注意：每个线程调用此方法时，传入的 queens 数组都是独立的，所以是线程安全的。
     */
    private void placeQueen(int[] queens, int row) {
        if (row == SIZE) {
            try {
                // 找到解，放入并发队列
                solutionQueue.put(queens.clone());
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            return;
        }

        for (int col = 0; col < SIZE; col++) {
            if (isValid(queens, row, col)) {
                queens[row] = col;
                placeQueen(queens, row + 1);
                queens[row] = -1; // 回溯
            }
        }
    }

    private boolean isValid(int[] queens, int row, int column) {
        for (int i = 1; i <= row; i++) {
            if (queens[row - i] == column
                    || queens[row - i] == column - i
                    || queens[row - i] == column + i) {
                return false;
            }
        }
        return true;
    }

    public static void main(String[] args) {
        launch(args);
    }
}