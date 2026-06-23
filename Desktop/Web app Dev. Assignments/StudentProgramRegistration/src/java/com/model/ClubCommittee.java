package com.model;

public class ClubCommittee {
    private String committeeID;
    private String name;
    private String email;
    private String password;
    private String phoneNo;
    private String position;
    private String program;
    private int year;

    public ClubCommittee() {}

    // Getters and Setters
    public String getCommitteeID() { return committeeID; }
    public void setCommitteeID(String committeeID) { this.committeeID = committeeID; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getPhoneNo() { return phoneNo; }
    public void setPhoneNo(String phoneNo) { this.phoneNo = phoneNo; }
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    // Getters and Setters for Program
    public String getProgram() { 
        return program; 
    }
    public void setProgram(String program) { 
        this.program = program; 
    }

    // Getters and Setters for Year
    public int getYear() { 
        return year; 
    }
    public void setYear(int year) { 
        this.year = year; 
    }
}