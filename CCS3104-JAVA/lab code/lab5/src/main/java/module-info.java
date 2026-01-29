module com.example.lab5 {
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

    opens com.example.lab5 to javafx.fxml;
    exports com.example.lab5;
}