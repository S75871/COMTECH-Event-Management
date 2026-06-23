<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.dao.DBConnection" %>
<!DOCTYPE html>
<html>
    <head>
        <title>UniVents - Reply Feedback</title>
        <link rel="stylesheet" type="text/css" href="style.css">
        <style>
            .form-container {
                max-width: 600px;
                margin: 0 auto;
                background-color: #f9f9f9;
                padding: 20px;
                border-radius: 8px;
                border: 1px solid #ddd;
            }
            /* Kotak Rujukan Komen Asal */
            .feedback-details {
                background-color: #e9ecef;
                padding: 15px;
                border-left: 5px solid #800000;
                margin-bottom: 20px;
                border-radius: 4px;
            }
            .feedback-details p {
                margin: 5px 0;
                font-size: 14px;
            }
            .form-group {
                margin-bottom: 15px;
            }
            .form-group label {
                font-weight: bold;
                display: block;
                margin-bottom: 5px;
            }
            textarea {
                width: 100%;
                height: 150px;
                padding: 10px;
                border: 1px solid #ccc;
                border-radius: 4px;
                font-family: inherit;
            }
            .btn-submit {
                background-color: #800000;
                color: white;
                padding: 10px 20px;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-weight: bold;
            }
            .btn-submit:hover {
                background-color: #b71c1c;
            }
            .btn-cancel {
                background-color: #ccc;
                color: black;
                padding: 10px 20px;
                text-decoration: none;
                border-radius: 4px;
                font-weight: bold;
                margin-left: 10px;
            }
        </style>
    </head>
    <body>
        <jsp:include page="navbar.jsp" />

        <div class="container" style="padding: 40px;">
            <div class="main-content">
                <h2>Reply to Feedback</h2>

                <%
                    // Ambil parameter dari URL
                    String feedbackID = request.getParameter("feedbackID");
                    String eventName = "N/A";
                    String originalComment = "N/A";

                    // Tarik butiran komen dari database berdasarkan feedbackID
                    if (feedbackID != null) {
                        try (Connection conn = DBConnection.getConnection();
                             PreparedStatement ps = conn.prepareStatement(
                                 "SELECT f.comment, e.eventName FROM feedback f " +
                                 "JOIN club_event e ON f.eventID = e.eventID " +
                                 "WHERE f.feedbackID = ?")) {
                            
                            ps.setString(1, feedbackID);
                            ResultSet rs = ps.executeQuery();
                            if (rs.next()) {
                                eventName = rs.getString("eventName");
                                originalComment = rs.getString("comment");
                            }
                        } catch (Exception e) {
                            out.println("");
                        }
                    }
                %>

                <div class="form-container">
                    
                    <div class="feedback-details">
                        <p><strong>Feedback ID:</strong> #<%= feedbackID %></p>
                        <p><strong>Event:</strong> <%= eventName %></p>
                        <p><strong>User's Comment:</strong> <em>"<%= originalComment %>"</em></p>
                    </div>

                    <form action="ReportFeedbackServlet" method="POST">
                        <input type="hidden" name="action" value="replyFeedback">
                        <input type="hidden" name="feedbackID" value="<%= feedbackID %>">
                        
                        <div class="form-group">
                            <label for="replyText">Your Reply Message:</label>
                            <textarea name="replyText" id="replyText" placeholder="Type your response to the user here..." required></textarea>
                        </div>
                        
                        <button type="submit" class="btn-submit">Send Reply</button>
                        <a href="ReportFeedbackServlet?action=viewAll" class="btn-cancel">Cancel</a>
                    </form>
                </div>

            </div>
        </div>
        
        <jsp:include page="footer.jsp" />
    </body>
</html>