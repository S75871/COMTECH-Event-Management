<%-- 
    Document   : manageFeedback
    Created on : 13 May 2026
    Author     : Ainaa Nadhirah
--%>

<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Feedback - COMTECH</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <style>
        .container { 
            padding: 30px; 
            max-width: 1200px; 
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
        
        /* Alert Messages */
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            padding: 12px 20px;
            border-radius: 6px;
            margin-bottom: 20px;
            border-left: 4px solid #28a745;
        }
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            padding: 12px 20px;
            border-radius: 6px;
            margin-bottom: 20px;
            border-left: 4px solid #dc3545;
        }
        
        /* Table Styling */
        table { 
            width: 100%; 
            border-collapse: collapse; 
            border: 2px solid black; 
        }
        th { 
            background-color: #e3f2fd; 
            color: black; 
            border: 2px solid black; 
            padding: 12px; 
            text-transform: uppercase;
            font-size: 13px;
        }
        td { 
            border: 2px solid black; 
            padding: 12px; 
            text-align: center; 
            font-size: 14px;
            color: #333; 
        }
        tr:nth-child(even) { background-color: #fcfcfc; }

        /* Action Buttons Styling */
        .btn-update {
            color: #0d47a1;
            text-decoration: none;
            font-weight: bold;
            margin-right: 15px;
        }
        .btn-delete {
            color: #d32f2f;
            text-decoration: none;
            font-weight: bold;
            margin-right: 15px;
        }
        .btn-reply {
            color: #2e7d32;
            text-decoration: none;
            font-weight: bold;
        }
        .btn-update:hover, .btn-delete:hover, .btn-reply:hover { 
            text-decoration: underline; 
        }
        .view-only { 
            color: #757575; 
            font-style: italic; 
            font-size: 13px; 
        }
        
        .badge-reply {
            background-color: #e8f5e9;
            color: #2e7d32;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }
    </style>
</head>
<body>

    <!-- ===== INI PERUBAHAN UTAMA: GUNA jsp:include UNTUK NAVBAR ===== -->
    <jsp:include page="navbar.jsp" />

    <div class="container">
        <div class="main-content">
            <h2>Manage Event Feedback</h2>
            
            <% 
                // Get user session data
                String role = (String) session.getAttribute("userRole"); 
                String userId = (String) session.getAttribute("userId");
                
                // Display messages
                String msg = request.getParameter("msg");
                String error = request.getParameter("error");
                
                if (msg != null) {
                    if ("Submitted".equals(msg)) {
            %>
                <div class="alert-success">✅ Your feedback has been submitted successfully!</div>
            <%      } else if ("Updated".equals(msg)) { %>
                <div class="alert-success">✅ Your feedback has been updated successfully!</div>
            <%      } else if ("Deleted".equals(msg)) { %>
                <div class="alert-success">✅ Feedback has been deleted successfully!</div>
            <%      } else if ("ReplySent".equals(msg)) { %>
                <div class="alert-success">✅ Your reply has been sent successfully!</div>
            <%      }
                } else if (error != null && "unauthorized".equals(error)) { 
            %>
                <div class="alert-error">⛔ You are not authorized to perform this action.</div>
            <% } %>
            
            <%
                // Retrieve the filtered list from Servlet
                List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("feedbackList");
                if (list == null) list = new ArrayList<>(); 
            %>

            <table>
                <thead>
                    <tr>
                        <th width="20%">Event Name</th>
                        <th width="8%">Rating</th>
                        <th width="35%">Comment</th>
                        <th width="12%">Date</th>
                        <th width="10%">Replies</th>
                        <th width="15%">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (list.isEmpty()) { %>
                        <tr>
                            <td colspan="6" style="padding: 30px; color: #757575;">No feedback records found.</td>
                        </tr>
                    <% } else { 
                        for(Map<String, Object> f : list) { 
                            int replyCount = (int) f.get("replyCount");
                            String feedbackID = String.valueOf(f.get("feedbackID"));
                            String comment = (String) f.get("comment");
                            String eventName = (String) f.get("eventName");
                            int rating = (int) f.get("rating");
                            String ownerID = (String) f.get("memberID");
                            boolean isOwner = userId != null && userId.equals(ownerID);
                    %>
                        <tr>
                            <td style="text-align: left; font-weight: bold;"><%= eventName %></td>
                            <td style="color: #f39c12; font-weight: bold;"><%= rating %> / 5</td>
                            <td style="text-align: left;"><%= comment %></td>
                            <td><%= f.get("submissionDate") %></td>
                            <td>
                                <a href="ReportFeedbackServlet?action=viewReplies&feedbackID=<%= feedbackID %>" class="btn-reply">
                                    <span class="badge-reply">💬 <%= replyCount %></span>
                                </a>
                            </td>
                            <td>
                                <%-- ACTION LOGIC BASED ON ROLE --%>
                                
                                <% if ("MEMBER".equals(role) && isOwner) { %>
                                    <%-- Members can Update and Delete their own feedback --%>
                                    <a href="updateFeedback.jsp?id=<%= feedbackID %>&comment=<%= comment %>&rating=<%= rating %>&eventID=<%= f.get("eventID") %>" 
                                       class="btn-update">Update</a>
                                    
                                    <a href="ReportFeedbackServlet?action=delete&id=<%= feedbackID %>" 
                                       class="btn-delete"
                                       onclick="return confirm('Are you sure you want to delete your feedback?')">Delete</a>

                                <% } else if ("COMMITTEE".equals(role)) { %>
                                    <%-- Committee can reply and delete any feedback --%>
                                    <a href="replyFeedback.jsp?feedbackID=<%= feedbackID %>" 
                                       class="btn-reply">Reply</a>
                                    
                                    <a href="ReportFeedbackServlet?action=delete&id=<%= feedbackID %>" 
                                       class="btn-delete"
                                       onclick="return confirm('As Committee, confirm deletion of this feedback?')">Delete</a>

                                <% } else if ("ADVISOR".equals(role)) { %>
                                    <%-- Advisor can reply to any feedback --%>
                                    <a href="replyFeedback.jsp?feedbackID=<%= feedbackID %>" 
                                       class="btn-reply">Reply</a>
                                    <span class="view-only">View Only</span>

                                <% } else { %>
                                    <%-- View Only for others --%>
                                    <span class="view-only">View Only</span>
                                <% } %>
                            </td>
                        </tr>
                    <% } } %>
                </tbody>
            </table>
        </div>
    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>