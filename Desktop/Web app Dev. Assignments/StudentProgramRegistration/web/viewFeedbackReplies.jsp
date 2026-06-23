<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    List<Map<String, String>> replies = (List<Map<String, String>>) request.getAttribute("repliesList");
%>
<!DOCTYPE html>
<html>
<head>
    <title>View Replies - UniVents</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <style>
        .reply-box {
            background: #fdf2f2; /* Latar belakang maroon cair */
            border-left: 4px solid #800000; /* Garisan tepi maroon */
            padding: 15px;
            margin-bottom: 15px;
            border-radius: 8px;
        }
        .reply-header {
            font-size: 12px;
            color: #555;
            margin-bottom: 8px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <jsp:include page="navbar.jsp" />
    
    <div style="max-width: 800px; margin: 40px auto; padding: 20px; background: white; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">
        <h2 style="color: #800000; border-bottom: 2px solid #eee; padding-bottom: 10px;">💬 Conversation History</h2>

        <% if (replies != null && !replies.isEmpty()) { 
            for (Map<String, String> reply : replies) { %>
                <div class="reply-box">
                    <div class="reply-header">
                        👤 Responded by: <%= reply.get("repliedBy") %> | 🕒 <%= reply.get("replyDate") %>
                    </div>
                    <div><%= reply.get("replyText") %></div>
                </div>
        <%  }
           } else { %>
            <p style="color: gray; font-style: italic;">No replies yet for this feedback.</p>
        <% } %>

        <div style="margin-top: 20px;">
            <a href="ReportFeedbackServlet?action=viewAll" class="btn-view" style="text-decoration: none; padding: 10px 20px; background: #757575; color: white; border-radius: 5px;">⬅️ Back to List</a>
            
            <a href="replyFeedback.jsp?feedbackID=<%= request.getAttribute("feedbackID") %>" class="btn-submit" style="text-decoration: none; padding: 10px 20px; background: #800000; color: white; border-radius: 5px; margin-left: 10px;">➕ Add Another Reply</a>
        </div>
    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>