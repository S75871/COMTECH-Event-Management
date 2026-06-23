<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, com.model.Event"%>
<%@page import="java.text.SimpleDateFormat"%>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"MEMBER".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    SimpleDateFormat timeFormatter = new SimpleDateFormat("hh:mm a");
%>

<!DOCTYPE html>
<html>
    <head>
        <title>UniVents - My Reservations</title>
        <link rel="stylesheet" type="text/css" href="style.css">
        <style>
            /* Styles for the Search and Filter Bar */
            .filter-bar {
                display: flex;
                gap: 15px;
                margin: 0 50px 20px;
                background: #f8f9fa;
                padding: 15px;
                border-radius: 8px;
                border: 1px solid #ddd;
            }
            .filter-bar input, .filter-bar select {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            .filter-bar .search-input {
                flex-grow: 1;
            }
        </style>
    </head>
    <body>
        <jsp:include page="navbar.jsp" />

        <div class="main-content">
            <h1 class="page-title">My Event Schedule</h1>
            <p style="margin: 0 50px 20px; color: #666;">View your reserved events or cancel your seat if you can no longer attend.</p>

            <% if ("cancel_success".equals(request.getParameter("msg"))) { %>
            <div style="margin: 0 50px 20px; padding: 15px; background: #d4edda; color: #155724; border-radius: 6px;">
                <strong>Success!</strong> Your reservation has been cancelled. Your seat is now available for someone else.
            </div>
            <% } %>

            <div class="filter-bar">
                <input type="text" id="searchInput" class="search-input" onkeyup="filterTable()" placeholder="Search by Event Name or Venue...">

                <input type="date" id="dateFilter" onchange="filterTable()" title="Filter by Date">

                <select id="timeFilter" onchange="filterTable()" title="Filter by Time">
                    <option value="">All Times</option>
                    <option value="AM">Morning (AM)</option>
                    <option value="PM">Afternoon/Evening (PM)</option>
                </select>

                <button type="button" class="btn-view" onclick="clearFilters()">Clear</button>
            </div>

            <div style="padding: 0 50px;">
                <table id="eventsTable">
                    <tr>
                        <th>Event Name</th>
                        <th>Date</th>
                        <th>Time</th>
                        <th>Venue</th>
                        <th>Action</th>
                    </tr>
                    <%
                        List<Event> events = (List<Event>) request.getAttribute("myEvents");
                        if (events != null && !events.isEmpty()) {
                            for (Event e : events) {
                                String timeString = timeFormatter.format(e.getStartTime()) + " - " + timeFormatter.format(e.getEndTime());

                                // Escape strings for JavaScript safety
                                String safeName = e.getEventName() != null ? e.getEventName().replace("'", "\\'").replace("\"", "&quot;") : "N/A";
                                String safeDesc = e.getDescription() != null ? e.getDescription().replace("\r", " ").replace("\n", " ").replace("'", "\\'").replace("\"", "&quot;") : "No description.";
                                String safeVenue = e.getVenue() != null ? e.getVenue().replace("'", "\\'").replace("\"", "&quot;") : "N/A";
                                String safeAJKs = e.getEventAJKs() != null ? e.getEventAJKs().replace("'", "\\'").replace("\"", "&quot;") : "TBA";

                                boolean isPastEvent = e.getEventDate().getTime() < System.currentTimeMillis();
                    %>
                    <tr>
                        <td><strong><%= e.getEventName()%></strong></td>
                        <td><%= e.getEventDate()%></td>
                        <td><%= timeString%></td>
                        <td><%= e.getVenue()%></td>
                        <td>
                            <button type="button" class="btn-view" onclick="viewDetails(
                                            '<%= safeName%>', '<%= e.getEventDate()%>', '<%= timeString%>',
                                            '<%= safeVenue%>', '<%= safeAJKs%>', '<%= safeDesc%>'
                                            )">View</button>

                            <% if (isPastEvent) {%>
                            <a href="feedbackForm.jsp?eventID=<%= e.getEventID()%>" 
                               style="background-color: #2e7d32; color: white; padding: 5px 10px; text-decoration: none; border-radius: 4px; font-size: 13px; margin-left: 5px;">
                                Feedback
                            </a>
                            <% } else {%>
                            <form action="EventServlet" method="POST" style="display:inline; margin-left: 5px;">
                                <input type="hidden" name="action" value="cancelRsvp">
                                <input type="hidden" name="eventID" value="<%= e.getEventID()%>">
                                <button type="submit" class="btn-reject" onclick="return confirm('Are you sure you want to cancel your seat?');">Cancel RSVP</button>
                            </form>
                            <% } %>
                        </td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="5" style="text-align: center; padding: 20px;">
                            You haven't registered for any events yet. <br><br>
                            <a href="EventServlet?action=browse" class="btn btn-blue">Browse Upcoming Events</a>
                        </td>
                    </tr>
                    <% }%>
                </table>

                <div id="detailsModal" class="modal" style="width: 45%; left: 27.5%;">
                    <h2 style="border-bottom: 2px solid #eee; padding-bottom: 10px;">Event Details</h2>
                    <p><strong>Event Name:</strong> <span id="detName"></span></p>
                    <p><strong>Date:</strong> <span id="detDate"></span></p>
                    <p><strong>Time:</strong> <span id="detTime"></span></p>
                    <p><strong>Venue:</strong> <span id="detVenue"></span></p>
                    <p><strong>Event AJKs:</strong> <span id="detAJKs"></span></p>
                    <hr style="border: 1px solid #eee; margin: 15px 0;">
                    <p><strong>Full Description:</strong></p>
                    <p id="detDesc" style="background: #f9f9f9; padding: 10px; border-radius: 4px; border: 1px solid #ddd;"></p>

                    <div style="text-align: right; margin-top: 20px;">
                        <button type="button" class="btn-cancel" onclick="document.getElementById('detailsModal').style.display = 'none'">Close Window</button>
                    </div>
                </div>

                <script>
                    function viewDetails(name, date, time, venue, ajks, desc) {
                        document.getElementById('detName').innerText = name;
                        document.getElementById('detDate').innerText = date;
                        document.getElementById('detTime').innerText = time;
                        document.getElementById('detVenue').innerText = venue;
                        document.getElementById('detAJKs').innerText = ajks;
                        document.getElementById('detDesc').innerText = desc;

                        document.getElementById('detailsModal').style.display = 'block';
                    }

                    // Client-Side Search and Filter Logic
                    function filterTable() {
                        let searchInput = document.getElementById("searchInput").value.toLowerCase().trim();
                        let dateInput = document.getElementById("dateFilter").value.trim();
                        let timeInput = document.getElementById("timeFilter").value.toUpperCase();

                        let table = document.getElementById("eventsTable");
                        let tr = table.getElementsByTagName("tr");

                        for (let i = 1; i < tr.length; i++) {
                            let tdName = tr[i].getElementsByTagName("td")[0];
                            let tdDate = tr[i].getElementsByTagName("td")[1];
                            let tdTime = tr[i].getElementsByTagName("td")[2];
                            let tdVenue = tr[i].getElementsByTagName("td")[3];

                            if (tdName && tdDate && tdTime && tdVenue) {
                                let nameText = (tdName.textContent || tdName.innerText).toLowerCase();
                                let dateText = (tdDate.textContent || tdDate.innerText).trim();
                                let timeText = (tdTime.textContent || tdTime.innerText).toUpperCase();
                                let venueText = (tdVenue.textContent || tdVenue.innerText).toLowerCase();

                                let matchesSearch = nameText.includes(searchInput) || venueText.includes(searchInput);
                                let matchesDate = (dateInput === "") || (dateText === dateInput);
                                let matchesTime = (timeInput === "") || timeText.includes(timeInput);

                                if (matchesSearch && matchesDate && matchesTime) {
                                    tr[i].style.display = "";
                                } else {
                                    tr[i].style.display = "none";
                                }
                            }
                        }
                    }

                    function clearFilters() {
                        document.getElementById("searchInput").value = "";
                        document.getElementById("dateFilter").value = "";
                        document.getElementById("timeFilter").value = "";
                        filterTable();
                    }
                </script>


                </body>
                <jsp:include page="footer.jsp"/>

                </html>