module com.example.lab6 {
    requires javafx.controls;
    requires javafx.fxml;
    requires javafx.web;
    requires java.rmi;

    requires org.controlsfx.controls;
    requires com.dlsc.formsfx;
    requires net.synedra.validatorfx;
    requires org.kordamp.ikonli.javafx;
    requires org.kordamp.bootstrapfx.core;
    requires eu.hansolo.tilesfx;
    requires com.almasb.fxgl.all;
    requires java.sql;

    opens com.example.lab6 to javafx.fxml;
    exports com.example.lab6;
}