package com.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        // Check for an environment variable named 'DB_ENV'
        // If set to 'CLOUD', use cloud credentials. Otherwise, default to 'LOCAL'.
        String env = System.getenv("DB_ENV");
        
        String url, user, password;

        if ("CLOUD".equals(env)) {
            url = "jdbc:mysql://gateway01.ap-southeast-1.prod.alicloud.tidbcloud.com:4000/db_facility_service?sslMode=VERIFY_IDENTITY&enabledTLSProtocols=TLSv1.2,TLSv1.3";
            user = "45uaSnmQRqEgnf9.root";
            password = "lU2LDysFrsekg5eZ";
        } else {
            // Local fallback
            url = "jdbc:mysql://localhost:3306/univents_db";
            user = "root";
            password = "admin";
        }

        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(url, user, password);
    }
}