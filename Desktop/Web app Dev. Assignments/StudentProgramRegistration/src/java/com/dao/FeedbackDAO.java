package com.dao;

import java.util.*;
import java.sql.*;

public class FeedbackDAO {

    public List<Map<String, Object>> getAllFeedback(String role, String userId) {
        List<Map<String, Object>> feedbackList = new ArrayList<>();
        // The SQL joins feedback with the club_event table to get the event names
        String sql = "SELECT f.*, e.eventName, "
                + "(SELECT COUNT(*) FROM feedback_replies fr WHERE fr.feedbackID = f.feedbackID) AS replyCount "
                + "FROM feedback f JOIN club_event e ON f.eventID = e.eventID";

        // Filter by member if necessary
        if ("MEMBER".equals(role)) {
            sql += " WHERE f.memberID = ?";
        }
        sql += " ORDER BY f.submissionDate DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {

            if ("MEMBER".equals(role)) {
                st.setString(1, userId);
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
        } catch (Exception e) {
            e.printStackTrace();
        }
        return feedbackList;
    }

    public String getEventName(String eventID) {
        String name = "Event Not Found";
        String sql = "SELECT eventName FROM club_event WHERE eventID = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, eventID);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                name = rs.getString("eventName");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return name;
    }

    public boolean addFeedback(String eventID, String memberID, int rating, String comment) {
        String sql = "INSERT INTO feedback (eventID, memberID, rating, comment, submissionDate) VALUES (?, ?, ?, ?, CURDATE())";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setString(1, eventID);
            st.setString(2, memberID);
            st.setInt(3, rating);
            st.setString(4, comment);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateFeedback(int feedbackID, int rating, String comment) {
        String sql = "UPDATE feedback SET rating = ?, comment = ?, submissionDate = CURDATE() WHERE feedbackID = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, rating);
            st.setString(2, comment);
            st.setInt(3, feedbackID);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public void deleteFeedback(int feedbackID) {
        try (Connection conn = DBConnection.getConnection()) {
            conn.prepareStatement("DELETE FROM feedback_replies WHERE feedbackID = " + feedbackID).executeUpdate();
            PreparedStatement st = conn.prepareStatement("DELETE FROM feedback WHERE feedbackID = ?");
            st.setInt(1, feedbackID);
            st.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean replyToFeedback(int feedbackID, String replierID, String replierRole, String replyText) {

        String sql = "INSERT INTO feedback_replies (feedbackID, replierID, replierRole, replyText, replyDate) VALUES (?, ?, ?, ?, NOW())";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {

            st.setInt(1, feedbackID);

            st.setString(2, replierID);

            st.setString(3, replierRole);

            st.setString(4, replyText);

            return st.executeUpdate() > 0;

        } catch (Exception e) {

            e.printStackTrace();

            return false;

        }

    }
}
