<%-- 
    Document   : feedbackForm
    Created on : 17 Jun 2026, 4:12:58 pm
    Author     : Ainaa Nadhirah
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // Authorization: Only Member can submit feedback
    String role = (String) session.getAttribute("userRole");
    if (!"MEMBER".equals(role)) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
    
    String eventID = request.getParameter("eventID");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Submit Feedback - COMTECH</title>
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
        
        .star-rating {
            color: #f39c12;
            font-size: 18px;
        }
    </style>
</head>
<body>

    <jsp:include page="navbar.jsp" />

    <div class="container">
        <div class="main-content">
            <h2>📝 Submit Event Feedback</h2>
            
            <form action="ReportFeedbackServlet" method="POST">
                <input type="hidden" name="action" value="submitFeedback">
                
                <div class="form-group">
                    <label for="eventID">Event:</label>
                    <select id="eventID" name="eventID" required>
                        <option value="">-- Select Event --</option>
                        <%
                            // Fetch events from database
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/comtech_db", "root", "");
                                String sql = "SELECT eventID, eventName FROM club_event WHERE status = 'Approved' ORDER BY eventDate DESC";
                                PreparedStatement st = conn.prepareStatement(sql);
                                ResultSet rs = st.executeQuery();
                                while (rs.next()) {
                                    String id = rs.getString("eventID");
                                    String name = rs.getString("eventName");
                                    String selected = (eventID != null && eventID.equals(id)) ? "selected" : "";
                        %>
                                    <option value="<%= id %>" <%= selected %>><%= name %></option>
                        <%
                                }
                                rs.close();
                                st.close();
                                conn.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="rating">Rating:</label>
                    <select id="rating" name="rating" required>
                        <option value="5">⭐⭐⭐⭐⭐ - Excellent</option>
                        <option value="4">⭐⭐⭐⭐ - Good</option>
                        <option value="3" selected>⭐⭐⭐ - Average</option>
                        <option value="2">⭐⭐ - Poor</option>
                        <option value="1">⭐ - Very Poor</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="comment">Comment:</label>
                    <textarea id="comment" name="comment" required placeholder="Share your experience about this event..."></textarea>
                </div>
                
                <div class="btn-group">
                    <button type="submit" class="btn-submit">📤 Submit Feedback</button>
                    <a href="ReportFeedbackServlet?action=viewAll" class="btn-cancel">❌ Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>