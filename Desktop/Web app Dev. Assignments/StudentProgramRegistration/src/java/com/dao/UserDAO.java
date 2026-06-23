package com.dao;

import com.model.ClubMember;
import com.model.ClubCommittee;
import com.dao.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    /* ==========================================================
       CREATE OPERATIONS (INSERT INTO BOTH TABLES)
       ========================================================== */
    // Register a new standard Club Member
    public boolean registerMember(ClubMember member) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // 1. Insert into central users table
            String sqlUser = "INSERT INTO users (userID, password, fullName, email, role) VALUES (?, ?, ?, ?, 'MEMBER')";
            try (PreparedStatement ps1 = conn.prepareStatement(sqlUser)) {
                ps1.setString(1, member.getMemberID());
                ps1.setString(2, member.getPassword());
                ps1.setString(3, member.getName());
                ps1.setString(4, member.getEmail());
                ps1.executeUpdate();
            }

            // 2. Insert into specific clubmember table
            String sqlMember = "INSERT INTO clubmember (memberID, name, email, password, phoneNo, program, year) VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps2 = conn.prepareStatement(sqlMember)) {
                ps2.setString(1, member.getMemberID());
                ps2.setString(2, member.getName());
                ps2.setString(3, member.getEmail());
                ps2.setString(4, member.getPassword());
                ps2.setString(5, member.getPhoneNo());
                ps2.setString(6, member.getProgram());
                ps2.setInt(7, member.getYear());
                ps2.executeUpdate();
            }

            conn.commit(); // Save both successfully
            return true;
        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    // Register a new Club Committee Member (AJK)
    public boolean registerCommittee(ClubCommittee committee) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // 1. Insert into central users table
            String sqlUser = "INSERT INTO users (userID, password, fullName, email, role) VALUES (?, ?, ?, ?, 'COMMITTEE')";
            try (PreparedStatement ps1 = conn.prepareStatement(sqlUser)) {
                ps1.setString(1, committee.getCommitteeID());
                ps1.setString(2, committee.getPassword());
                ps1.setString(3, committee.getName());
                ps1.setString(4, committee.getEmail());
                ps1.executeUpdate();
            }

            // 2. Insert into specific clubcommittee table
            String sqlCom = "INSERT INTO clubcommittee (committeeID, name, email, password, phoneNo, position, program, year) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps2 = conn.prepareStatement(sqlCom)) {
                ps2.setString(1, committee.getCommitteeID());
                ps2.setString(2, committee.getName());
                ps2.setString(3, committee.getEmail());
                ps2.setString(4, committee.getPassword());
                ps2.setString(5, committee.getPhoneNo());
                ps2.setString(6, committee.getPosition());
                ps2.setString(7, committee.getProgram());
                ps2.setInt(8, committee.getYear());
                ps2.executeUpdate();
            }

            conn.commit(); // Save both successfully
            return true;
        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    /* ==========================================================
       AUTHENTICATION OPERATION
       ========================================================== */
    // Authenticate user login across all three role tables
    public String[] authenticateUser(String email, String password) {
        try (Connection conn = DBConnection.getConnection()) {

            // 1. Check if user is a Committee Member
            String sqlCmd = "SELECT committeeID, name FROM ClubCommittee WHERE email=? AND password=?";
            try (PreparedStatement ps = conn.prepareStatement(sqlCmd)) {
                ps.setString(1, email);
                ps.setString(2, password);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    return new String[]{"COMMITTEE", rs.getString("committeeID"), rs.getString("name")};
                }
            }

            // 2. Check if user is an Advisor
            String sqlAdv = "SELECT advisorID, name FROM ClubAdvisor WHERE email=? AND password=?";
            try (PreparedStatement ps = conn.prepareStatement(sqlAdv)) {
                ps.setString(1, email);
                ps.setString(2, password);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    return new String[]{"ADVISOR", rs.getString("advisorID"), rs.getString("name")};
                }
            }

            // 3. Check if user is a Standard Member
            String sqlMem = "SELECT memberID, name FROM ClubMember WHERE email=? AND password=?";
            try (PreparedStatement ps = conn.prepareStatement(sqlMem)) {
                ps.setString(1, email);
                ps.setString(2, password);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    return new String[]{"MEMBER", rs.getString("memberID"), rs.getString("name")};
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null; // Return null if credentials don't match any table
    }

    /* ==========================================================
       READ OPERATIONS (FETCHING ROSTERS)
       ========================================================== */
    // Fetch ONLY Standard Members for the Advisor Dashboard
    public List<ClubMember> getAllStandardMembers() {
        List<ClubMember> members = new ArrayList<>();
        String sql = "SELECT * FROM ClubMember ORDER BY name ASC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ClubMember m = new ClubMember();
                m.setMemberID(rs.getString("memberID"));
                m.setName(rs.getString("name"));
                m.setEmail(rs.getString("email"));
                m.setPhoneNo(rs.getString("phoneNo"));
                m.setProgram(rs.getString("program"));
                m.setYear(rs.getInt("year"));
                members.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return members;
    }

    // Fetch ONLY Committee Members for the Advisor Dashboard
    public List<ClubCommittee> getAllCommitteeMembers() {
        List<ClubCommittee> committee = new ArrayList<>();
        String sql = "SELECT * FROM ClubCommittee ORDER BY position ASC, name ASC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ClubCommittee c = new ClubCommittee();
                c.setCommitteeID(rs.getString("committeeID"));
                c.setName(rs.getString("name"));
                c.setEmail(rs.getString("email"));
                c.setPhoneNo(rs.getString("phoneNo"));
                c.setPosition(rs.getString("position"));
                c.setProgram(rs.getString("program"));
                c.setYear(rs.getInt("year"));
                committee.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return committee;
    }

    /* ==========================================================
       DELETE OPERATION (DELETE FROM BOTH TABLES)
       ========================================================== */
    public boolean deleteMember(String id) {
        boolean isDeleted = false;
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Delete from specific tables first
            try (PreparedStatement psMem = conn.prepareStatement("DELETE FROM clubmember WHERE memberID = ?")) {
                psMem.setString(1, id);
                psMem.executeUpdate();
            }
            try (PreparedStatement psCom = conn.prepareStatement("DELETE FROM clubcommittee WHERE committeeID = ?")) {
                psCom.setString(1, id);
                psCom.executeUpdate();
            }

            // 2. Delete from central users table
            try (PreparedStatement psUsers = conn.prepareStatement("DELETE FROM users WHERE userID = ?")) {
                psUsers.setString(1, id);
                if (psUsers.executeUpdate() > 0) {
                    isDeleted = true;
                }
            }

            conn.commit();
        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
        return isDeleted;
    }

    /* ==========================================================
       PROFILE MANAGEMENT (ADDED)
       ========================================================== */
    // 1. Fetch data to display on profile page
    public String[] getUserProfileData(String id, String role) {
        String[] data = new String[6]; // [0]Email, [1]Phone, [2]Prog/Pos, [3]Year, [4]Password, [5]Name
        String sql = "";
        try (Connection conn = DBConnection.getConnection()) {
            if ("COMMITTEE".equals(role)) {
                sql = "SELECT email, phoneNo, program, year, password, name FROM ClubCommittee WHERE committeeID=?";
            } else if ("ADVISOR".equals(role)) {
                sql = "SELECT email, phoneNo, '' as program, 0 as year, password, name FROM ClubAdvisor WHERE advisorID=?";
            } else {
                sql = "SELECT email, phoneNo, program, year, password, name FROM ClubMember WHERE memberID=?";
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, id);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    data[0] = rs.getString("email");
                    data[1] = rs.getString("phoneNo");
                    data[2] = rs.getString("program");
                    data[3] = String.valueOf(rs.getInt("year"));
                    data[4] = rs.getString("password");
                    data[5] = rs.getString("name");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return data;
    }

    // 2. Update phone and password based on role
    public boolean updateProfile(String id, String role, String phone, String password) {
        String table = "ClubMember";
        String idColumn = "memberID";

        if ("COMMITTEE".equals(role)) {
            table = "ClubCommittee";
            idColumn = "committeeID";
        } else if ("ADVISOR".equals(role)) {
            table = "ClubAdvisor";
            idColumn = "advisorID";
        }

        String sql = "UPDATE " + table + " SET phoneNo=?, password=? WHERE " + idColumn + "=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setString(2, password);
            ps.setString(3, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            return false;
        }
    }
}
