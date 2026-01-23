package com.example.lab5;

import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;

public class RMIRegistryServer {
    public static void main(String[] args) throws RemoteException {
        LocateRegistry.createRegistry(1099);
        System.out.println("RMI Registry started on port 1099.");
        // 保持进程不退出
        while (true) {

            try { Thread.sleep(1000); } catch (InterruptedException ignored) {}
        }
    }
}