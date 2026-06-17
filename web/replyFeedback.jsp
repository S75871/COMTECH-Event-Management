<%-- 
    Document   : replyFeedback
    Created on : 17 Jun 2026, 10:36:52 am
    Author     : Ainaa Nadhirah
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // Authorization: Only Committee or Advisor can reply
    String role = (String) session.getAttribute("userRole");
    if (!"COMMITTEE".equals(role) && !"ADVISOR".equals(role)) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
    
    String feedbackID = request.getParameter("feedbackID");
    if (feedbackID == null || feedbackID.isEmpty()) {
        response.sendRedirect("ReportFeedbackServlet?action=viewAll");
        return;
    }
    
    // Fetch feedback details
    String eventName = "";
    String comment = "";
    int rating = 0;
    String memberName = "";
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/comtech_db", "root", "");
        
        String sql = "SELECT f.*, e.eventName, u.fullName as memberName FROM feedback f " +
                     "JOIN club_event e ON f.eventID = e.eventID " +
                     "JOIN users u ON f.memberID = u.userID " +
                     "WHERE f.feedbackID = ?";
        PreparedStatement st = conn.prepareStatement(sql);
        st.setInt(1, Integer.parseInt(feedbackID));
        ResultSet rs = st.executeQuery();
        
        if (rs.next()) {
            eventName = rs.getString("eventName");
            comment = rs.getString("comment");
            rating = rs.getInt("rating");
            memberName = rs.getString("memberName");
        }
        
        rs.close();
        st.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Reply to Feedback - COMTECH</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <style>
        .container { 
            padding: 30px; 
            max-width: 800px; 
            margin: auto; 
        }

        .main-content {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }

        h2 { 
            color: #0d47a1; 
            margin-top: 0;
            border-bottom: 2px solid #f0f5ff;
            padding-bottom: 10px;
            margin-bottom: 25px;
        }
        
        .feedback-box {
            background: #f8f9fa;
            border-left: 4px solid #0d47a1;
            padding: 15px 20px;
            border-radius: 6px;
            margin-bottom: 25px;
        }
        .feedback-box .event-name {
            font-weight: bold;
            color: #0d47a1;
            font-size: 18px;
        }
        .feedback-box .member {
            color: #555;
            font-size: 14px;
        }
        .feedback-box .rating {
            color: #f39c12;
            font-weight: bold;
        }
        .feedback-box .comment {
            margin-top: 10px;
            color: #333;
            background: white;
            padding: 10px;
            border-radius: 4px;
            border: 1px solid #ddd;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            font-weight: bold;
            margin-bottom: 8px;
            color: #333;
        }
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid #ccc;
            border-radius: 8px;
            font-family: inherit;
            font-size: 14px;
            resize: vertical;
            min-height: 150px;
            box-sizing: border-box;
            transition: border-color 0.3s;
        }
        .form-group textarea:focus {
            border-color: #0d47a1;
            outline: none;
        }
        
        .btn-group {
            display: flex;
            gap: 15px;
            margin-top: 20px;
        }
        .btn-submit {
            background-color: #0d47a1;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
            font-size: 16px;
            transition: 0.3s;
        }
        .btn-submit:hover {
            background-color: #1565c0;
        }
        .btn-cancel {
            background-color: #757575;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            font-size: 16px;
            transition: 0.3s;
        }
        .btn-cancel:hover {
            background-color: #616161;
        }
    </style>
</head>
<body>

    <jsp:include page="navbar.jsp" />

    <div class="container">
        <div class="main-content">
            <h2>💬 Reply to Feedback</h2>
            
            <div class="feedback-box">
                <div class="event-name">📋 <%= eventName %></div>
                <div class="member">👤 From: <strong><%= memberName %></strong></div>
                <div class="rating">⭐ Rating: <%= rating %> / 5</div>
                <div class="comment"><%= comment %></div>
            </div>
            
            <form action="ReportFeedbackServlet" method="POST">
                <input type="hidden" name="action" value="replyFeedback">
                <input type="hidden" name="feedbackID" value="<%= feedbackID %>">
                
                <div class="form-group">
                    <label for="replyText">Your Reply:</label>
                    <textarea id="replyText" name="replyText" required placeholder="Type your reply here..."></textarea>
                </div>
                
                <div class="btn-group">
                    <button type="submit" class="btn-submit">📤 Send Reply</button>
                    <a href="ReportFeedbackServlet?action=viewReplies&feedbackID=<%= feedbackID %>" class="btn-cancel">❌ Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>