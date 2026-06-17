package com.lab.dao;

import com.lab.model.ClubMember;
import com.lab.model.ClubCommittee;
import com.lab.dao.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    /* ==========================================================
       CREATE OPERATIONS (INSERT)
       ========================================================== */

    // Register a new standard Club Member
    public boolean registerMember(ClubMember member) {
        String sql = "INSERT INTO ClubMember (memberID, name, email, password, phoneNo, program, year) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, member.getMemberID());
            ps.setString(2, member.getName());
            ps.setString(3, member.getEmail());
            ps.setString(4, member.getPassword());
            ps.setString(5, member.getPhoneNo());
            ps.setString(6, member.getProgram());
            ps.setInt(7, member.getYear());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Register a new Club Committee Member (AJK)
    public boolean registerCommittee(ClubCommittee committee) {
        String sql = "INSERT INTO ClubCommittee (committeeID, name, email, password, phoneNo, position, program, year) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, committee.getCommitteeID());
            ps.setString(2, committee.getName());
            ps.setString(3, committee.getEmail());
            ps.setString(4, committee.getPassword());
            ps.setString(5, committee.getPhoneNo());
            ps.setString(6, committee.getPosition());
            ps.setString(7, committee.getProgram());
            ps.setInt(8, committee.getYear());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
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
                if (rs.next()) return new String[]{"COMMITTEE", rs.getString("committeeID"), rs.getString("name")};
            }
            
            // 2. Check if user is an Advisor
            String sqlAdv = "SELECT advisorID, name FROM ClubAdvisor WHERE email=? AND password=?";
            try (PreparedStatement ps = conn.prepareStatement(sqlAdv)) {
                ps.setString(1, email);
                ps.setString(2, password);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) return new String[]{"ADVISOR", rs.getString("advisorID"), rs.getString("name")};
            }
            
            // 3. Check if user is a Standard Member
            String sqlMem = "SELECT memberID, name FROM ClubMember WHERE email=? AND password=?";
            try (PreparedStatement ps = conn.prepareStatement(sqlMem)) {
                ps.setString(1, email);
                ps.setString(2, password);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) return new String[]{"MEMBER", rs.getString("memberID"), rs.getString("name")};
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
       DELETE OPERATION
       ========================================================== */

    // Delete a member (Scans both tables to ensure deletion works regardless of role)
    public boolean deleteMember(String id) {
        boolean isDeleted = false;
        
        // Attempt deletion from Standard Member table first
        String sqlMem = "DELETE FROM ClubMember WHERE memberID = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sqlMem)) {
            ps.setString(1, id);
            if (ps.executeUpdate() > 0) isDeleted = true;
        } catch (Exception e) { e.printStackTrace(); }

        // Attempt deletion from Committee table
        String sqlCom = "DELETE FROM ClubCommittee WHERE committeeID = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sqlCom)) {
            ps.setString(1, id);
            if (ps.executeUpdate() > 0) isDeleted = true;
        } catch (Exception e) { e.printStackTrace(); }

        return isDeleted; // Returns true if it successfully deleted from either table
    }
}