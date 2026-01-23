package com.example.lab4;
import javafx.application.Application;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.stage.Stage;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.*;

public class ParallelEightQueens extends Application {
    public static final int SIZE = 8;
    // 使用 LinkedList 代替 ArrayList，存储 int[] 数组
    private List<int[]> solutions = new LinkedList<>();
    private int currentSolutionIndex = 0;

    // UI 组件
    private Label[][] labels = new Label[SIZE][SIZE];
    private Label statusLabel = new Label("Searching...");
    private Button btNext = new Button("Next");
    private Button btPrev = new Button("Previous");

    @Override
    public void start(Stage primaryStage) {
        // 1. 执行并行搜索算法
        searchParallel();
        // 2. 构建 UI 布局
        BorderPane mainPane = new BorderPane();
        // 棋盘区域
        GridPane chessBoard = new GridPane();
        chessBoard.setAlignment(Pos.CENTER);
        for (int i = 0; i < SIZE; i++) {
            for (int j = 0; j < SIZE; j++) {
                Rectangle bg = new Rectangle(60, 60);
                if ((i + j) % 2 == 0) bg.setFill(Color.WHITE);
                else bg.setFill(Color.LIGHTGRAY);

                labels[i][j] = new Label();
                labels[i][j].setPrefSize(60, 60);
                labels[i][j].setAlignment(Pos.CENTER);
                labels[i][j].setFont(Font.font("Arial", FontWeight.BOLD, 40));
                labels[i][j].setTextFill(Color.BLACK);

                String bgStyle = ((i + j) % 2 == 0) ? "-fx-background-color: white;" : "-fx-background-color: lightgray;";
                labels[i][j].setStyle(bgStyle + "-fx-border-color: black;");

                chessBoard.add(labels[i][j], j, i);
            }
        }
        mainPane.setCenter(chessBoard);

        // 底部控制区域
        HBox controlPanel = new HBox(10);
        controlPanel.setAlignment(Pos.CENTER);
        controlPanel.setStyle("-fx-padding: 10px;");
        controlPanel.getChildren().addAll(btPrev, statusLabel, btNext);
        mainPane.setBottom(controlPanel);

        // 3. 设置按钮事件
        btNext.setOnAction(e -> {
            if (currentSolutionIndex < solutions.size() - 1) {
                currentSolutionIndex++;
                updateBoard();
            }
        });

        btPrev.setOnAction(e -> {
            if (currentSolutionIndex > 0) {
                currentSolutionIndex--;
                updateBoard();
            }
        });

        // 4. 显示第一个解
        if (!solutions.isEmpty()) {
            updateBoard();
        } else {
            statusLabel.setText("No solutions found.");
        }

        // 5. 设置舞台
        Scene scene = new Scene(mainPane, 550, 600);
        primaryStage.setTitle("Parallel Eight Queens Solutions");
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    private void updateBoard() {
        if (solutions.isEmpty()) return;

        // 清空棋盘
        for (int i = 0; i < SIZE; i++) {
            for (int j = 0; j < SIZE; j++) {
                labels[i][j].setText("");
            }
        }

        // 放置皇后
        int[] currentSolution = solutions.get(currentSolutionIndex);
        for (int row = 0; row < SIZE; row++) {
            int col = currentSolution[row];
            labels[row][col].setText("♛");
        }

        statusLabel.setText("Solution " + (currentSolutionIndex + 1) + " / " + solutions.size());

        btPrev.setDisable(currentSolutionIndex == 0);
        btNext.setDisable(currentSolutionIndex == solutions.size() - 1);
    }

    private void searchParallel() {
        // 使用固定线程池
        ExecutorService executor = Executors.newFixedThreadPool(SIZE);
        List<Future<LinkedList<int[]>>> futures = new LinkedList<>();

        // 启动 8 个任务，分别搜索第一行皇后位于 0-7 列的情况
        for (int i = 0; i < SIZE; i++) {
            final int startCol = i;
            Callable<LinkedList<int[]>> task = () -> {
                LinkedList<int[]> subSolutions = new LinkedList<>();
                int[] queens = new int[SIZE];
                // 初始化
                for (int k = 0; k < SIZE; k++) queens[k] = -1;

                // 固定第一行的位置
                queens[0] = startCol;

                // 使用课件中的迭代逻辑进行搜索 (Search for a solution)
                // 从第 1 行开始 (row 1)
                int k = 1;
                while (k >= 1) { // 只要不回退到第0行（因为第0行是固定的），就继续循环
                    // 在第 k 行寻找放置位置
                    int j = findPosition(k, queens);
                    if (j < 0) {
                        queens[k] = -1;
                        k--; // 回溯到上一行
                    } else {
                        queens[k] = j;
                        k++; // 前进到下一行

                        if (k == SIZE) {
                            // 找到一个完整解
                            int[] sol = new int[SIZE];
                            System.arraycopy(queens, 0, sol, 0, SIZE);
                            subSolutions.add(sol);

                            // 关键点：为了找到所有解，我们假装当前行还需要继续寻找
                            // 回溯到上一行，让 findPosition 从当前位置的下一个位置继续找
                            k--;
                        }
                    }
                }
                return subSolutions;
            };
            futures.add(executor.submit(task));
        }

        // 收集结果
        try {
            for (Future<LinkedList<int[]>> future : futures) {
                solutions.addAll(future.get());
            }
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
        } finally {
            executor.shutdown();
        }
    }

    // 改编自 EightQueens.java 的 findPosition，增加了 queens 参数以支持并行
    public int findPosition(int k, int[] queens) {
        int start = queens[k] + 1; // 搜索下一个可能的位置

        for (int j = start; j < SIZE; j++) {
            if (isValid(k, j, queens))
                return j; // (k, j) 是可以放置皇后的位置
        }

        return -1;
    }


    public boolean isValid(int row, int column, int[] queens) {
        for (int i = 1; i <= row; i++)
            if (queens[row - i] == column // Check column
                    || queens[row - i] == column - i // Check upleft diagonal
                    || queens[row - i] == column + i) // Check upright diagonal
                return false; // Conflict
        return true; // No conflict
    }

    public static void main(String[] args) {
        launch(args);
    }
}