package com.example.lab6;

import java.rmi.Remote;
import java.rmi.RemoteException;

public interface ScoreService extends Remote {
    // 定义一个方法：输入名字，返回成绩
    double getScore(String name) throws RemoteException;
}