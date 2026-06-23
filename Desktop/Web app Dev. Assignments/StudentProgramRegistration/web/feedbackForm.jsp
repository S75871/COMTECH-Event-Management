<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.dao.FeedbackDAO"%>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"MEMBER".equals(role)) { response.sendRedirect("login.jsp"); return; }
    
    String eventID = request.getParameter("eventID");
    FeedbackDAO fDAO = new FeedbackDAO();
    String eventName = fDAO.getEventName(eventID);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Submit Feedback</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <style>
        .feedback-card {
            background: #ffffff;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            max-width: 500px;
            margin: 40px auto;
        }
        .feedback-card h2 { color: #0d47a1; margin-bottom: 1.5rem; text-align: center; }
        .form-group { margin-bottom: 1.2rem; }
        .form-group label { display: block; margin-bottom: 0.5rem; font-weight: 600; color: #333; }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            box-sizing: border-box; /* Ensures padding doesn't break width */
        }
        .btn-submit {
            width: 100%;
            background: #0d47a1;
            color: white;
            padding: 12px;
            border: none;
            border-radius: 6px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.3s;
        }
        .btn-submit:hover { background: #1565c0; }
        .disabled-input { background: #f8f9fa; color: #666; cursor: not-allowed; }
    </style>
</head>
<body>
    <jsp:include page="navbar.jsp" />

    <div class="feedback-card">
        <h2>📝 Event Feedback</h2>
        <form action="ReportFeedbackServlet" method="POST">
            <input type="hidden" name="action" value="submitFeedback">
            <input type="hidden" name="eventID" value="<%= eventID %>">
            
            <div class="form-group">
                <label>Event Name:</label>
                <input type="text" value="<%= eventName %>" disabled class="disabled-input">
            </div>
            
            <div class="form-group">
                <label>Rating:</label>
                <select name="rating" required>
                    <option value="5">⭐⭐⭐⭐⭐ - Excellent</option>
                    <option value="4">⭐⭐⭐⭐ - Good</option>
                    <option value="3" selected>⭐⭐⭐ - Average</option>
                    <option value="2">⭐⭐ - Poor</option>
                    <option value="1">⭐ - Very Poor</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Comment:</label>
                <textarea name="comment" rows="4" required placeholder="Tell us what you thought about the event..."></textarea>
            </div>
            
            <button type="submit" class="btn-submit">Submit Feedback</button>
        </form>
    </div>
            <jsp:include page="footer.jsp" />
</body>
</html>