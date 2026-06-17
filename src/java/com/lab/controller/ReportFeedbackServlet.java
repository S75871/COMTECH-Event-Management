/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.lab.controller;

import com.lab.dao.DBConnection;
import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;


/**
 *
 * @author Ainaa Nadhirah
 */
@WebServlet(name = "ReportFeedbackServlet", urlPatterns = {"/ReportFeedbackServlet"})
public class ReportFeedbackServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        try {
            if ("viewAll".equals(action)) {
                viewFeedbackList(request, response);
            } else if ("delete".equals(action)) {
                deleteFeedback(request, response);
            } else if ("generateReport".equals(action)) {
                generateReport(request, response);
            } else if ("submitFeedback".equals(action)) {
                submitFeedback(request, response);
            } else if ("updateFeedback".equals(action)) {
                updateFeedback(request, response);
            } else if ("replyFeedback".equals(action)) {
                replyFeedback(request, response);
            } else if ("viewReplies".equals(action)) {
                viewReplies(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    /**
     * MFR08: Allows members to submit new feedback
     */
    private void submitFeedback(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String eventIDStr = request.getParameter("eventID");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");
        
        if (eventIDStr == null || eventIDStr.isEmpty() || ratingStr == null || ratingStr.isEmpty()) {
            response.sendRedirect("feedbackForm.jsp?error=missing_data");
            return;
        }

        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userId"); // Changed from userID to userId
        String role = (String) session.getAttribute("userRole");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO feedback (eventID, memberID, rating, comment, submissionDate) VALUES (?, ?, ?, ?, CURDATE())";
            PreparedStatement st = conn.prepareStatement(sql);
            st.setInt(1, Integer.parseInt(eventIDStr));
            st.setString(2, userID);
            st.setInt(3, Integer.parseInt(ratingStr));
            st.setString(4, comment);
            st.executeUpdate();
            
            response.sendRedirect("ReportFeedbackServlet?action=viewAll&msg=Submitted");
        }
    }

    /**
     * Update existing feedback (For Members only)
     */
    private void updateFeedback(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int feedbackID = Integer.parseInt(request.getParameter("feedbackID"));
        int rating = Integer.parseInt(request.getParameter("rating"));
        String comment = request.getParameter("comment");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE feedback SET rating = ?, comment = ?, submissionDate = CURDATE() WHERE feedbackID = ?";
            PreparedStatement st = conn.prepareStatement(sql);
            st.setInt(1, rating);
            st.setString(2, comment);
            st.setInt(3, feedbackID);
            st.executeUpdate();
            
            response.sendRedirect("ReportFeedbackServlet?action=viewAll&msg=Updated");
        }
    }

    /**
     * Review & Monitor: Member sees only their own, Committee/Advisor sees ALL
     * Now also fetches reply count for each feedback
     */
    private void viewFeedbackList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");
        String userID = (String) session.getAttribute("userId");

        List<Map<String, Object>> feedbackList = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT f.*, e.eventName, " +
                         "(SELECT COUNT(*) FROM feedback_replies fr WHERE fr.feedbackID = f.feedbackID) AS replyCount " +
                         "FROM feedback f JOIN club_event e ON f.eventID = e.eventID";
            
            // Logically filter based on role
            if ("MEMBER".equals(role)) {
                sql += " WHERE f.memberID = ?";
            }
            
            sql += " ORDER BY f.submissionDate DESC";

            PreparedStatement st = conn.prepareStatement(sql);
            if ("MEMBER".equals(role)) {
                st.setString(1, userID);
            }

            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("feedbackID", rs.getInt("feedbackID"));
                row.put("eventID", rs.getInt("eventID"));
                row.put("eventName", rs.getString("eventName"));
                row.put("rating", rs.getInt("rating"));
                row.put("comment", rs.getString("comment"));
                row.put("memberID", rs.getString("memberID"));
                row.put("submissionDate", rs.getDate("submissionDate"));
                row.put("replyCount", rs.getInt("replyCount"));
                feedbackList.add(row);
            }
            
            request.setAttribute("feedbackList", feedbackList);
            request.getRequestDispatcher("manageFeedback.jsp").forward(request, response);
        }
    }

    /**
     * Delete feedback entry - Committee can delete any, Member can only delete their own
     */
    private void deleteFeedback(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int feedbackID = Integer.parseInt(request.getParameter("id"));
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");
        String userID = (String) session.getAttribute("userId");

        try (Connection conn = DBConnection.getConnection()) {
            // Check permission: Member can only delete their own feedback
            if ("MEMBER".equals(role)) {
                String checkSql = "SELECT memberID FROM feedback WHERE feedbackID = ?";
                PreparedStatement checkSt = conn.prepareStatement(checkSql);
                checkSt.setInt(1, feedbackID);
                ResultSet rs = checkSt.executeQuery();
                if (rs.next()) {
                    String ownerID = rs.getString("memberID");
                    if (!ownerID.equals(userID)) {
                        response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=unauthorized");
                        return;
                    }
                }
            }
            
            // Also delete all replies associated with this feedback
            String deleteRepliesSql = "DELETE FROM feedback_replies WHERE feedbackID = ?";
            PreparedStatement replySt = conn.prepareStatement(deleteRepliesSql);
            replySt.setInt(1, feedbackID);
            replySt.executeUpdate();
            
            String sql = "DELETE FROM feedback WHERE feedbackID = ?";
            PreparedStatement st = conn.prepareStatement(sql);
            st.setInt(1, feedbackID);
            st.executeUpdate();
            
            response.sendRedirect("ReportFeedbackServlet?action=viewAll&msg=Deleted");
        }
    }

    /**
     * NEW: Reply to feedback - Committee or Advisor can reply
     */
    private void replyFeedback(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int feedbackID = Integer.parseInt(request.getParameter("feedbackID"));
        String replyText = request.getParameter("replyText");
        
        HttpSession session = request.getSession();
        String replierID = (String) session.getAttribute("userId");
        String replierRole = (String) session.getAttribute("userRole");

        // Only Committee or Advisor can reply
        if (!"COMMITTEE".equals(replierRole) && !"ADVISOR".equals(replierRole)) {
            response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=unauthorized");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO feedback_replies (feedbackID, replierID, replierRole, replyText, replyDate) VALUES (?, ?, ?, ?, CURDATE())";
            PreparedStatement st = conn.prepareStatement(sql);
            st.setInt(1, feedbackID);
            st.setString(2, replierID);
            st.setString(3, replierRole);
            st.setString(4, replyText);
            st.executeUpdate();
            
            response.sendRedirect("ReportFeedbackServlet?action=viewReplies&feedbackID=" + feedbackID + "&msg=ReplySent");
        }
    }

    /**
     * NEW: View all replies for a specific feedback
     */
    private void viewReplies(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int feedbackID = Integer.parseInt(request.getParameter("feedbackID"));
        
        List<Map<String, Object>> replyList = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection()) {
            // Get feedback details first
            String feedbackSql = "SELECT f.*, e.eventName FROM feedback f JOIN club_event e ON f.eventID = e.eventID WHERE f.feedbackID = ?";
            PreparedStatement feedbackSt = conn.prepareStatement(feedbackSql);
            feedbackSt.setInt(1, feedbackID);
            ResultSet feedbackRs = feedbackSt.executeQuery();
            
            Map<String, Object> feedback = new HashMap<>();
            if (feedbackRs.next()) {
                feedback.put("feedbackID", feedbackRs.getInt("feedbackID"));
                feedback.put("eventName", feedbackRs.getString("eventName"));
                feedback.put("rating", feedbackRs.getInt("rating"));
                feedback.put("comment", feedbackRs.getString("comment"));
                feedback.put("memberID", feedbackRs.getString("memberID"));
                feedback.put("submissionDate", feedbackRs.getDate("submissionDate"));
            }
            
            // Get all replies
            String replySql = "SELECT * FROM feedback_replies WHERE feedbackID = ? ORDER BY replyDate ASC";
            PreparedStatement replySt = conn.prepareStatement(replySql);
            replySt.setInt(1, feedbackID);
            ResultSet replyRs = replySt.executeQuery();
            
            while (replyRs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("replyID", replyRs.getInt("replyID"));
                row.put("replierID", replyRs.getString("replierID"));
                row.put("replierRole", replyRs.getString("replierRole"));
                row.put("replyText", replyRs.getString("replyText"));
                row.put("replyDate", replyRs.getDate("replyDate"));
                replyList.add(row);
            }
            
            request.setAttribute("feedback", feedback);
            request.setAttribute("replyList", replyList);
            request.getRequestDispatcher("viewFeedbackReplies.jsp").forward(request, response);
        }
    }

    /**
     * CFR08: Generate Dynamic Report with Table and Chart data
     */
    private void generateReport(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");
        String viewMode = request.getParameter("viewMode");

        if (monthStr == null || yearStr == null) {
            response.sendRedirect("generateReportForm.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT e.*, " +
                         "(SELECT COUNT(*) FROM event_registration r WHERE r.eventID = e.eventID AND r.status = 'Confirmed') as actualPart, " +
                         "(SELECT AVG(f.rating) FROM feedback f WHERE f.eventID = e.eventID) as avgScore " +
                         "FROM club_event e " +
                         "WHERE MONTH(e.eventDate) = ? AND YEAR(e.eventDate) = ? AND e.status = 'Approved' " +
                         "GROUP BY e.eventID";
            
            PreparedStatement st = conn.prepareStatement(sql);
            st.setInt(1, Integer.parseInt(monthStr));
            st.setInt(2, Integer.parseInt(yearStr));
            
            ResultSet rs = st.executeQuery();

            List<Map<String, Object>> reportData = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("eventName", rs.getString("eventName"));
                row.put("eventDate", rs.getDate("eventDate"));
                row.put("venue", rs.getString("venue"));
                row.put("category", "Academic");
                row.put("level", "Universiti");
                
                // Format time
                Time startTime = rs.getTime("startTime");
                Time endTime = rs.getTime("endTime");
                String timeStr = (startTime != null && endTime != null) ? 
                    startTime.toString().substring(0, 5) + " - " + endTime.toString().substring(0, 5) : "TBA";
                row.put("time", timeStr);
                
                int totalPart = rs.getInt("capacity");
                int actualPart = rs.getInt("actualPart");
                row.put("totalPart", totalPart);
                row.put("actualPart", actualPart);
                
                double attendanceRate = (totalPart > 0) ? ((double) actualPart / totalPart) * 100 : 0;
                row.put("attendanceRate", attendanceRate);
                
                double score = rs.getDouble("avgScore");
                row.put("avgScore", rs.wasNull() ? 0.0 : score);
                
                reportData.add(row);
            }

            // Convert Month Number to Name for Dynamic Header
            String[] monthNames = {"", "January", "February", "March", "April", "May", "June", 
                                   "July", "August", "September", "October", "November", "December"};
            String monthName = monthNames[Integer.parseInt(monthStr)];

            request.setAttribute("reportData", reportData);
            request.setAttribute("viewMode", (viewMode == null) ? "both" : viewMode);
            request.setAttribute("selectedMonthName", monthName);
            request.setAttribute("selectedYear", yearStr);
            
            request.getRequestDispatcher("viewReport.jsp").forward(request, response);
        }
    }
}