<%-- 
    Document   : viewFeedbackReplies
    Created on : 17 Jun 2026, 10:35:09 am
    Author     : Ainaa Nadhirah
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Feedback Replies - COMTECH</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <style>
        .container { 
            padding: 30px; 
            max-width: 900px; 
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
        .feedback-box .date {
            color: #757575;
            font-size: 12px;
            margin-top: 8px;
        }
        
        .reply-item {
            background: #f8f9fa;
            border-left: 4px solid #2e7d32;
            padding: 15px 20px;
            border-radius: 6px;
            margin-bottom: 15px;
        }
        .reply-item .reply-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
        }
        .reply-item .replier {
            font-weight: bold;
            color: #2e7d32;
        }
        .reply-item .replier-role {
            font-size: 12px;
            background: #e8f5e9;
            padding: 2px 10px;
            border-radius: 12px;
            color: #2e7d32;
        }
        .reply-item .reply-date {
            color: #757575;
            font-size: 12px;
        }
        .reply-item .reply-text {
            color: #333;
            margin-top: 5px;
        }
        
        .no-replies {
            color: #757575;
            text-align: center;
            padding: 30px;
            font-style: italic;
        }
        
        .btn-back {
            background-color: #0d47a1;
            color: white;
            padding: 10px 25px;
            border: none;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            margin-top: 20px;
        }
        .btn-back:hover {
            background-color: #1565c0;
        }
        
        .btn-reply-here {
            background-color: #2e7d32;
            color: white;
            padding: 10px 25px;
            border: none;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            margin-top: 20px;
            margin-left: 10px;
        }
        .btn-reply-here:hover {
            background-color: #388e3c;
        }
        
        .action-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-top: 10px;
        }
    </style>
</head>
<body>

    <jsp:include page="navbar.jsp" />

    <div class="container">
        <div class="main-content">
            <h2>💬 Feedback & Replies</h2>
            
            <%
                Map<String, Object> feedback = (Map<String, Object>) request.getAttribute("feedback");
                List<Map<String, Object>> replyList = (List<Map<String, Object>>) request.getAttribute("replyList");
                String role = (String) session.getAttribute("userRole");
                
                if (feedback != null) {
            %>
            <div class="feedback-box">
                <div class="event-name">📋 <%= feedback.get("eventName") %></div>
                <div class="rating">⭐ Rating: <%= feedback.get("rating") %> / 5</div>
                <div class="comment"><%= feedback.get("comment") %></div>
                <div class="date">📅 Submitted: <%= feedback.get("submissionDate") %></div>
            </div>
            
            <h3 style="color: #2e7d32; margin-top: 30px; margin-bottom: 15px;">📨 Replies (<%= replyList != null ? replyList.size() : 0 %>)</h3>
            
            <% if (replyList != null && !replyList.isEmpty()) { 
                for (Map<String, Object> reply : replyList) {
                    String replierRole = (String) reply.get("replierRole");
                    String roleLabel = "COMMITTEE".equals(replierRole) ? "Committee" : "Advisor";
                    String roleColor = "COMMITTEE".equals(replierRole) ? "#2e7d32" : "#0d47a1";
                    String roleBg = "COMMITTEE".equals(replierRole) ? "#e8f5e9" : "#e3f2fd";
            %>
            <div class="reply-item">
                <div class="reply-header">
                    <span class="replier">👤 <%= reply.get("replierID") %></span>
                    <span class="replier-role" style="background: <%= roleBg %>; color: <%= roleColor %>;"><%= roleLabel %></span>
                    <span class="reply-date">📅 <%= reply.get("replyDate") %></span>
                </div>
                <div class="reply-text"><%= reply.get("replyText") %></div>
            </div>
            <%      } 
                } else { %>
            <div class="no-replies">No replies yet for this feedback.</div>
            <% } %>
            
            <div class="action-buttons">
                <a href="ReportFeedbackServlet?action=viewAll" class="btn-back">⬅ Back to Feedback List</a>
                
                <% if ("COMMITTEE".equals(role) || "ADVISOR".equals(role)) { 
                    String feedbackID = String.valueOf(feedback.get("feedbackID"));
                %>
                    <a href="replyFeedback.jsp?feedbackID=<%= feedbackID %>" class="btn-reply-here">💬 Reply to this Feedback</a>
                <% } %>
            </div>
            
            <% } else { %>
            <div class="no-replies">Feedback not found.</div>
            <a href="ReportFeedbackServlet?action=viewAll" class="btn-back">⬅ Back to Feedback List</a>
            <% } %>
        </div>
    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>