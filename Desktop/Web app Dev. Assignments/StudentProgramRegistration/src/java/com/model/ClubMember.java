package com.model;

public class ClubMember {
    private String memberID; // Changed from int to String
    private String name;
    private String email;
    private String password;
    private String phoneNo;
    private String program;
    private int year;

    public ClubMember() {}

    // Getters and Setters
    public String getMemberID() { return memberID; }
    public void setMemberID(String memberID) { this.memberID = memberID; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getPhoneNo() { return phoneNo; }
    public void setPhoneNo(String phoneNo) { this.phoneNo = phoneNo; }

    public String getProgram() { return program; }
    public void setProgram(String program) { this.program = program; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }
}