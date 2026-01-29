package com.example.lab5;

import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

public class RegisterCircleServer {
    public static void main(String[] args) throws Exception {
        String host = (args.length > 0) ? args[0] : "localhost";
        int port = (args.length > 1) ? Integer.parseInt(args[1]) : 1099;

        CircleService service = new CircleServiceImpl();

        Registry registry = LocateRegistry.getRegistry(host, port);
        registry.rebind("CircleService", service);

        System.out.println("CircleService bound in registry at " + host + ":" + port);
        System.out.println("Server is ready.");
        // 保持进程不退出（可选，但建议）
        while (true) {
            try { Thread.sleep(1000); } catch (InterruptedException ignored) {}
        }
    }
}