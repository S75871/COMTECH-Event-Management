<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String navRole = (String) session.getAttribute("userRole");
    String currentUserId = (String) session.getAttribute("userId");
%>
<div class="navbar">
    <div class="logo">
        <a href="home.jsp" style="display: flex; align-items: center; text-decoration: none; color: white; font-family: Palatino">
            <img src="images/UniVents.png" alt="UniVents Logo" class="nav-logo-img">
            <span style="font-size: 24px; font-weight: bold; margin: 0; color: #ffffff !important; text-decoration: none !important;">UniVents</span>
        </a>
    </div>
    
    <div class="nav-links">
        <a href="home.jsp">Home</a>
        
        <% if ("ADVISOR".equals(navRole)) { %>
            <a href="EventServlet?action=listPending">Event Approval</a>
            <a href="MemberServlet">Manage Members</a>
            <a href="EventServlet?action=advisorReservations">Reservations</a> 
            <a href="ReportFeedbackServlet?action=viewAll">Feedback</a>
            

        <% } else if ("COMMITTEE".equals(navRole)) { %>
            <a href="createEvent.jsp">Manage Events</a>
            <a href="ManageMembersServlet">Manage Members</a>
            <a href="EventServlet?action=committeeReservations">Reservations</a> 
            <a href="ReportFeedbackServlet?action=viewAll">Feedback</a>
            <a href="generateReportForm.jsp">Reports</a>
            

        <% } else if ("MEMBER".equals(navRole)) { %>
            <a href="EventServlet?action=browse">Browse Events</a>        
            <a href="EventServlet?action=myReservations">My Reservations</a>
            <a href="ReportFeedbackServlet?action=viewAll">My Feedback</a>
        <% } %>

        <div class="profile-menu">
            <div class="profile-icon">👤</div>
            <div class="dropdown-content">
                <a href="ProfileServlet" style="color: blue !important; font-weight: 600 !important;">Manage Profile</a>
                <hr style="margin: 0; border: none; border-top: 1px solid #eee;">
                <a href="login.jsp" style="color: #F44336 !important; font-weight: 600 !important;">Logout</a>
            </div>
        </div>

    </div>
</div>