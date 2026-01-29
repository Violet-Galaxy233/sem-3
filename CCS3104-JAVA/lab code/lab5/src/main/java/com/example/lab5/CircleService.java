package com.example.lab5;

import java.rmi.Remote;
import java.rmi.RemoteException;

public interface CircleService extends Remote {
    double area(double radius) throws RemoteException;
}