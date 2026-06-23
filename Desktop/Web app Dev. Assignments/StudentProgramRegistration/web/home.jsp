<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, com.dao.EventDAO, com.model.Event"%>
<%
    String role = (String) session.getAttribute("userRole");
    if (role == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    EventDAO dao = new EventDAO();
%>
<!DOCTYPE html>
<html>
<head>
    <title>UniVents - Dashboard</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    
</head>
<body>
    <jsp:include page="navbar.jsp" />

    <div class="dashboard-header">
        <h1>Welcome, <%= session.getAttribute("userName")%>!</h1>
        <p>Your centralized hub for all faculty academic and event activities.</p>
        <span style="background: var(--btn-blue); color: white; padding: 5px 15px; border-radius: 20px; font-size: 0.8em; font-weight: bold;">
            Logged in as: <%= role%>
        </span>
    </div>

    <div class="grid-container">
        <%-- Role-Based Cards --%>
        <% if ("ADVISOR".equals(role)) { %>
            <div class="card"><h3>Event Approvals</h3><p>Review and approve/reject proposals.</p><a href="EventServlet?action=listPending" class="btn btn-blue">Review Proposals</a></div>
            <div class="card"><h3>Member Directory</h3><p>Manage club members.</p><a href="MemberServlet" class="btn btn-blue">Manage Roster</a></div>
            <div class="card"><h3>Monthly Reports</h3><p>View analytics.</p><a href="generateReportForm.jsp" class="btn btn-blue">View Reports</a></div>
        <% } else if ("COMMITTEE".equals(role)) { %>
            <div class="card"><h3>Create Event</h3><p>Draft new event proposals.</p><a href="createEvent.jsp" class="btn btn-green">Draft Proposal</a></div>
            <div class="card"><h3>Review Feedback</h3><p>Moderate comments.</p><a href="ReportFeedbackServlet?action=viewAll" class="btn btn-blue">Moderate Feedback</a></div>
        <% } else if ("MEMBER".equals(role)) { %>
            <div class="card"><h3>Upcoming Events</h3><p>Browse events.</p><a href="EventServlet?action=browse" class="btn btn-blue">Browse & RSVP</a></div>
            <div class="card"><h3>My Reservations</h3><p>Check schedules.</p><a href="EventServlet?action=myReservations" class="btn btn-blue">View Schedule</a></div>
        <% } %>
    </div>

    <%-- PENDING REQUESTS WIDGET --%>
    <% if ("ADVISOR".equals(role) || "COMMITTEE".equals(role)) { %>
        <div class="widget-card">
            <h3>Recent Pending Requests</h3>
            <table>
                <tr><th>Event Name</th><th>Date</th><th>Status</th></tr>
                <%
                    List<Event> recent = dao.getRecentPendingEvents(5);
                    if (recent != null && !recent.isEmpty()) {
                        for (Event e : recent) {
                %>
                <tr>
                    <td><%= e.getEventName() %></td>
                    <td><%= e.getEventDate() %></td>
                    <td><span class="badge-pending"><%= e.getStatus() %></span></td>
                </tr>
                <%      } 
                    } else {
                %>
                <tr><td colspan="3">No events awaiting approval.</td></tr>
                <% } %>
            </table>
            <br>
            <a href="EventServlet?action=listPending" class="btn btn-blue">View All Pending</a>
        </div>
    <% } %>
    
    <%-- DECISION HISTORY WIDGET --%>
    <% if ("ADVISOR".equals(role) || "COMMITTEE".equals(role)) { %>
        <div class="widget-card">
            <h3>Event Decision History</h3>
            <table>
                <tr><th>Event Name</th><th>Date</th><th>Status</th><th>Action</th></tr>
                <%
                    List<Event> history = dao.getRecentEventHistory(5);
                    if (history != null && !history.isEmpty()) {
                        for (Event e : history) {
                            String badgeClass = "Approved".equals(e.getStatus()) ? "badge-approved" : "badge-rejected";
                            String safeName = e.getEventName() != null ? e.getEventName().replace("'", "\\'").replace("\"", "&quot;") : "N/A";
                            String safeComment = e.getAdvisorComment() != null ? e.getAdvisorComment().replace("\r", " ").replace("\n", " ").replace("'", "\\'").replace("\"", "&quot;") : "None";
                %>
                <tr>
                    <td><%= e.getEventName() %></td>
                    <td><%= e.getEventDate() %></td>
                    <td><span class="<%= badgeClass %>"><%= e.getStatus() %></span></td>
                    <td>
                        <button type="button" class="btn-view-sm" onclick="viewHistory('<%= safeName %>', '<%= e.getStatus() %>', '<%= safeComment %>')">View Reason</button>
                    </td>
                </tr>
                <%      } 
                    } else { 
                %>
                <tr><td colspan="4">No historical records found.</td></tr>
                <% } %>
            </table>
        </div>
    <% } %>

    <div id="historyModal" class="modal">
        <h3 style="border-bottom: 1px solid #eee; padding-bottom: 10px;">Decision Details</h3>
        <p><strong>Event:</strong> <span id="histName"></span></p>
        <p><strong>Status:</strong> <span id="histStatus" style="font-weight:bold;"></span></p>
        <p><strong>Advisor Reasoning:</strong></p>
        <p id="histComment" style="background: #f9f9f9; padding: 12px; border-radius: 4px; border: 1px solid #ddd;"></p>
        
        <div style="text-align: right; margin-top: 15px;">
            <button type="button" class="btn-view-sm" style="background-color: #6c757d;" onclick="document.getElementById('historyModal').style.display='none'">Close</button>
        </div>
    </div>

    <jsp:include page="footer.jsp" />

    <script>
        function viewHistory(name, status, comment) {
            document.getElementById('histName').innerText = name;
            
            let statusEl = document.getElementById('histStatus');
            statusEl.innerText = status;
            if (status === 'Approved') statusEl.style.color = 'green';
            else if (status === 'Rejected') statusEl.style.color = 'red';
            
            document.getElementById('histComment').innerText = comment;
            document.getElementById('historyModal').style.display = 'block';
        }
    </script>
</body>
</html>