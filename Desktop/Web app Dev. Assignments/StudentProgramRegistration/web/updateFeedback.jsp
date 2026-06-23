<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"MEMBER".equals(role)) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
    
    String feedbackID = request.getParameter("id");
    String currentComment = request.getParameter("comment");
    String currentRating = request.getParameter("rating");
    
    if (feedbackID == null || feedbackID.isEmpty()) {
        response.sendRedirect("ReportFeedbackServlet?action=viewAll");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>UniVents - Update Feedback</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <style>
        .container { 
            padding: 30px; 
            max-width: 700px; 
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
        
        .form-group {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }
        .form-group label {
            width: 150px;
            font-weight: bold;
            color: #333;
        }
        .form-group input, .form-group textarea, .form-group select {
            flex: 1;
            padding: 10px 15px;
            border: 2px solid #ccc;
            border-radius: 8px;
            font-family: inherit;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        .form-group input:focus, .form-group textarea:focus, .form-group select:focus {
            border-color: #0d47a1;
            outline: none;
        }
        .form-group textarea {
            resize: vertical;
            min-height: 120px;
        }
        .form-group select {
            width: auto;
            flex: 1;
        }
        
        .btn-group {
            display: flex;
            gap: 15px;
            margin-top: 20px;
            padding-left: 150px;
        }
        .btn-update {
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
        .btn-update:hover {
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
            <h2>✏️ Update Your Feedback</h2>
            
            <form action="ReportFeedbackServlet" method="POST">
                <input type="hidden" name="action" value="updateFeedback">
                <input type="hidden" name="feedbackID" value="<%= feedbackID %>">
                
                <div class="form-group">
                    <label for="rating">Rating:</label>
                    <select id="rating" name="rating" required>
                        <option value="5" <%= "5".equals(currentRating) ? "selected" : "" %>>⭐⭐⭐⭐⭐ - Excellent</option>
                        <option value="4" <%= "4".equals(currentRating) ? "selected" : "" %>>⭐⭐⭐⭐ - Good</option>
                        <option value="3" <%= "3".equals(currentRating) ? "selected" : "" %>>⭐⭐⭐ - Average</option>
                        <option value="2" <%= "2".equals(currentRating) ? "selected" : "" %>>⭐⭐ - Poor</option>
                        <option value="1" <%= "1".equals(currentRating) ? "selected" : "" %>>⭐ - Very Poor</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="comment">Comment:</label>
                    <textarea id="comment" name="comment" required><%= currentComment %></textarea>
                </div>
                
                <div class="btn-group">
                    <button type="submit" class="btn-update">💾 Update Feedback</button>
                    <a href="ReportFeedbackServlet?action=viewAll" class="btn-cancel">❌ Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>