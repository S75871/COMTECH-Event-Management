<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
    <head>
        <title>UniVents - Manage Feedback</title>
        <link rel="stylesheet" type="text/css" href="style.css">
        <style>
            /* Modern Table Styling */
            .table-wrapper {
                width: 100%;
                overflow-x: auto;
                margin-top: 20px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                border: 1px solid #ddd;
            }
            th {
                background-color: #800000;
                color: white;
                padding: 12px;
                text-align: left;
            }
            td {
                padding: 12px;
                border-bottom: 1px solid #ddd;
            }
            .btn-update {
                color: #800000;
                text-decoration: none;
                font-weight: bold;
                margin-right: 10px;
            }
            .btn-delete {
                color: #b71c1c;
                text-decoration: none;
                font-weight: bold;
            }
            .btn-reply {
                color: #0d47a1;
                text-decoration: none;
                font-weight: bold;
                margin-right: 10px;
            }
            .btn-fee {
                color: #2e7d32;
                text-decoration: none;
                font-weight: bold;
                margin-right: 10px;
            }
        </style>
    </head>
    <body>
        <jsp:include page="navbar.jsp" />

        <div class="container" style="padding: 40px;">
            <div class="main-content">
                <h2>Manage Event Feedback</h2>

                <%-- Feedback List Retrieval --%>
                <%
                    List<Map<String, Object>> feedbackList = (List<Map<String, Object>>) request.getAttribute("feedbackList");
                    String role = (String) session.getAttribute("userRole");
                    String userId = (String) session.getAttribute("userId");
                %>

                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Event</th>
                                <th>Rating</th>
                                <th>Comment</th>
                                <th>Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (feedbackList == null || feedbackList.isEmpty()) { %>
                            <tr><td colspan="5" style="text-align: center;">No feedback records found.</td></tr>
                            <% } else {
                                for (Map<String, Object> f : feedbackList) {
                                    int feedbackID = (int) f.get("feedbackID");
                                    String eventName = (String) f.get("eventName");
                                    int rating = (int) f.get("rating");
                                    String comment = (String) f.get("comment");
                                    String ownerID = (String) f.get("memberID");

                                    // Pastikan tiada error kalau replyCount bernilai null
                                    Object countObj = f.get("replyCount");
                                    int replyCount = (countObj != null) ? ((Number) countObj).intValue() : 0;
                            %>
                            <tr>
                                <td><%= eventName%></td>
                                <td><%= rating%> / 5</td>
                                <td><%= comment%></td>
                                <td><%= f.get("submissionDate")%></td>
                                <td>
                                    <% if ("MEMBER".equals(role) && userId.equals(ownerID)) {%>
                                    <a href="updateFeedback.jsp?id=<%= feedbackID%>" class="btn-update">Update</a>
                                    <a href="ReportFeedbackServlet?action=delete&id=<%= feedbackID%>" class="btn-delete" onclick="return confirm('Delete?')">Delete</a>

                                    <% } else if ("COMMITTEE".equals(role) || "ADVISOR".equals(role)) {%>
                                    <a href="replyFeedback.jsp?feedbackID=<%= feedbackID%>" class="btn-reply">Reply</a>

                                    <a href="ReportFeedbackServlet?action=viewReplies&feedbackID=<%= feedbackID%>"class="btn-reply">
                                        View Replies (<%= replyCount%>)
                                    </a>

                                    <a href="ReportFeedbackServlet?action=delete&id=<%= feedbackID%>" class="btn-delete" onclick="return confirm('Padam feedback ini?')">Delete</a>
                                    <% } %>
                                </td>
                            </tr>
                            <% }
                            }%>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <jsp:include page="footer.jsp" />
    </body>
</html>