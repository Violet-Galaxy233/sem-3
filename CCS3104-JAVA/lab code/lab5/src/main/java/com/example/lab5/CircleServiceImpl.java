package com.example.lab5;
import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;

public class CircleServiceImpl extends UnicastRemoteObject implements CircleService {

    public CircleServiceImpl() throws RemoteException {
        super();
    }

    @Override
    public double area(double radius) throws RemoteException {
        if (radius < 0) {
            throw new RemoteException("Radius cannot be negative.");
        }
        return Math.PI * radius * radius;
    }
}