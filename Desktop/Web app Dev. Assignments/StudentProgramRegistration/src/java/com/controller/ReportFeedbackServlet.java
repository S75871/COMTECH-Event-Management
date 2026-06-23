package com.controller;

import com.dao.*;
import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "ReportFeedbackServlet", urlPatterns = {"/ReportFeedbackServlet"})
public class ReportFeedbackServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("viewAll".equals(action)) {
                viewFeedbackList(request, response);
            } else if ("delete".equals(action)) {
                deleteFeedback(request, response);
            } else if ("submitFeedback".equals(action)) {
                submitFeedback(request, response);
            } else if ("updateFeedback".equals(action)) {
                updateFeedback(request, response);
            } else if ("replyFeedback".equals(action)) {
                replyFeedback(request, response);
            } else if ("viewReplies".equals(action)) {
                viewReplies(request, response);
            } else if ("generateReport".equals(action)) {
                generateReport(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "Ralat sistem: " + e.getMessage());
        }
    }

    private void viewFeedbackList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");
        String userID = (String) session.getAttribute("userId");

        List<Map<String, Object>> feedbackList = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT f.*, e.eventName, u.fullName as memberName FROM feedback f "
                    + "LEFT JOIN club_event e ON f.eventID = e.eventID "
                    + "LEFT JOIN users u ON f.memberID = u.userID WHERE 1=1 ";

            if ("MEMBER".equals(role)) {
                sql += " AND f.memberID = ? ";
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
                row.put("eventName", rs.getString("eventName"));
                row.put("rating", rs.getInt("rating"));
                row.put("comment", rs.getString("comment"));
                row.put("memberID", rs.getString("memberID"));

                row.put("memberName", rs.getString("memberName")); 
                row.put("submissionDate", rs.getDate("submissionDate"));

                PreparedStatement st2 = conn.prepareStatement("SELECT COUNT(*) FROM feedback_replies WHERE feedbackID = ?");
                st2.setInt(1, rs.getInt("feedbackID"));
                ResultSet rs2 = st2.executeQuery();
                if (rs2.next()) {
                    row.put("replyCount", rs2.getInt(1));
                }

                feedbackList.add(row);
            }

            request.setAttribute("feedbackList", feedbackList);
            request.getRequestDispatcher("manageFeedback.jsp").forward(request, response);
        }
    }

    private void submitFeedback(HttpServletRequest request, HttpServletResponse response) throws Exception {
        if (new FeedbackDAO().addFeedback(request.getParameter("eventID"),
                (String) request.getSession().getAttribute("userId"),
                Integer.parseInt(request.getParameter("rating")),
                request.getParameter("comment"))) {
            response.sendRedirect("ReportFeedbackServlet?action=viewAll&msg=Submitted");
        } else {
            response.sendRedirect("feedbackForm.jsp?error=failed");
        }
    }

    private void deleteFeedback(HttpServletRequest request, HttpServletResponse response) throws Exception {
        new FeedbackDAO().deleteFeedback(Integer.parseInt(request.getParameter("id")));
        response.sendRedirect("ReportFeedbackServlet?action=viewAll&msg=Deleted");
    }

    private void updateFeedback(HttpServletRequest request, HttpServletResponse response) throws Exception {
        new FeedbackDAO().updateFeedback(Integer.parseInt(request.getParameter("feedbackID")),
                Integer.parseInt(request.getParameter("rating")),
                request.getParameter("comment"));
        response.sendRedirect("ReportFeedbackServlet?action=viewAll&msg=Updated");
    }

    private void replyFeedback(HttpServletRequest request, HttpServletResponse response) throws Exception {
        new FeedbackDAO().replyToFeedback(Integer.parseInt(request.getParameter("feedbackID")),
                (String) request.getSession().getAttribute("userId"),
                (String) request.getSession().getAttribute("userRole"),
                request.getParameter("replyText"));
        response.sendRedirect("ReportFeedbackServlet?action=viewAll&msg=ReplySent");
    }

    private void viewReplies(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String feedbackID = request.getParameter("feedbackID");
        List<Map<String, String>> repliesList = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement st = conn.prepareStatement("SELECT * FROM feedback_replies WHERE feedbackID = ? ORDER BY replyDate ASC");
            st.setInt(1, Integer.parseInt(feedbackID));
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                Map<String, String> reply = new HashMap<>();
                reply.put("replyText", rs.getString("replyText"));
                reply.put("repliedBy", rs.getString("replierRole"));
                reply.put("replyDate", rs.getString("replyDate"));
                repliesList.add(reply);
            }
            request.setAttribute("repliesList", repliesList);
            request.setAttribute("feedbackID", feedbackID);
            request.getRequestDispatcher("viewFeedbackReplies.jsp").forward(request, response);
        }
    }

    private void generateReport(HttpServletRequest request, HttpServletResponse response) throws Exception {
        request.getRequestDispatcher("viewReport.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }
}
