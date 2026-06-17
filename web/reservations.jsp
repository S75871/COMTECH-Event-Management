<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, com.lab.model.Event, java.text.SimpleDateFormat"%>
<%
    String role = (String) session.getAttribute("userRole");
    // This attribute name matches the "eventList" we set in the EventServlet
    List<Event> events = (List<Event>) request.getAttribute("eventList");
    java.text.SimpleDateFormat timeFormatter = new java.text.SimpleDateFormat("hh:mm a");
%>
<!DOCTYPE html>
<html>
    <head>
        <title>COMTECH - Reservations</title>
        <link rel="stylesheet" type="text/css" href="style.css">
        <style>
            .participant-box {
                background: #f8f9fa;
                border: 1px solid #ddd;
                padding: 15px;
                border-radius: 6px;
                max-height: 200px;
                overflow-y: auto;
                font-size: 14px;
                margin-top: 10px;
            }
            /* Styling for the numbered list to make it neat */
            .participant-box ol {
                margin-left: 20px;
                padding-left: 10px;
                line-height: 1.8;
                margin-top: 0;
                margin-bottom: 0;
            }
            .participant-box li {
                border-bottom: 1px solid #eee;
                padding-bottom: 5px;
                margin-bottom: 5px;
            }
            .participant-box li:last-child {
                border-bottom: none;
                margin-bottom: 0;
                padding-bottom: 0;
            }
        </style>
    </head>
    <body>
        <jsp:include page="navbar.jsp" />

        <div class="main-content">
            <h1 class="page-title">Reservations Management</h1>
            <div style="padding: 0 50px;">
                <table id="eventsTable">
                    <tr>
                        <th>Event Name</th>
                        <th>Start Time</th>
                        <th>End Time</th>
                        <th>Date</th>
                        <th>Venue</th>
                        <% if (!"MEMBER".equals(role)) { %> <th>Capacity</th> <% } %>
                        <th>Action</th>
                    </tr>
                    <% if (events != null && !events.isEmpty()) {
                            for (Event e : events) {
                                boolean isPast = e.getEventDate().getTime() < System.currentTimeMillis();
                    %>
                    <tr>
                        <td><strong><%= e.getEventName()%></strong></td>
                        <td><%= timeFormatter.format(e.getStartTime())%></td>
                        <td><%= timeFormatter.format(e.getEndTime())%></td>
                        <td><%= e.getEventDate()%></td>
                        <td><%= e.getVenue()%></td>
                        <% if (!"MEMBER".equals(role)) {%>
                        <td><%= e.getRegisteredCount()%> / <%= e.getCapacity()%></td>
                        <% }%>
                        <td>
                            <button type="button" class="btn-view" onclick="viewDetails(
                                            '<%= e.getEventName().replace("'", "\\'")%>',
                                            '<%= e.getEventAJKs() != null ? e.getEventAJKs().replace("'", "\\'") : "N/A"%>',
                                            '<%= e.getDescription() != null ? e.getDescription().replace("\n", " ").replace("'", "\\'") : "No description"%>',
                                            '<%= e.getParticipantNames() != null ? e.getParticipantNames().replace("'", "\\'") : ""%>',
                                            '<%= e.getStartTime()%>',
                                            '<%= e.getEndTime()%>')">View</button>

                            <% if ("MEMBER".equals(role) && !isPast) {%>
                            <form action="EventServlet" method="POST" style="display:inline; margin-left: 5px;">
                                <input type="hidden" name="action" value="cancelRsvp">
                                <input type="hidden" name="eventID" value="<%= e.getEventID()%>">
                                <button type="submit" class="btn-cancel" onclick="return confirm('Cancel RSVP?')">Cancel</button>
                            </form>
                            <% } else if ("MEMBER".equals(role) && isPast) { %>
                            <span class="badge-rejected" style="margin-left:5px;">Finished</span>
                            <% } %>
                        </td>
                    </tr>
                    <% }
                    } else { %>
                    <tr><td colspan="5" style="text-align:center; padding: 20px;">No reservations found.</td></tr>
                    <% } %>
                </table>
            </div>
        </div>

        <div id="detailsModal" class="modal" style="display:none; position:fixed; top:15%; left:25%; width:50%; background:white; padding:20px; border-radius:8px; box-shadow:0 0 15px rgba(0,0,0,0.3); z-index:1000;">
            <h2>Event: <span id="modTitle"></span></h2>
            <p><strong>AJKs:</strong> <span id="modAJKs"></span></p>
            <p><strong>Description:</strong> <span id="modDesc"></span></p>

            <% if (!"MEMBER".equals(role)) { %>
            <p style="margin-bottom: 5px;"><strong>Participants:</strong></p>
            <div id="modPart" class="participant-box"></div>
            <% }%>

            <div style="text-align: right; margin-top: 20px;">
                <button class="btn-cancel" onclick="document.getElementById('detailsModal').style.display = 'none'">Close Window</button>
            </div>
        </div>

        <script>
            function viewDetails(name, ajks, desc, participants, ) {
                document.getElementById('modTitle').innerText = name;
                document.getElementById('modAJKs').innerText = ajks;
                document.getElementById('modDesc').innerText = desc;
                document.getElementById('modDesc').innerText = desc;

                let partBox = document.getElementById('modPart');
                if (partBox) {
                    if (!participants || participants === "null" || participants === "") {
                        partBox.innerHTML = "<span style='color: gray; font-style: italic;'>No students have registered yet.</span>";
                    } else {
                        // Split by '###' to get an array of students
                        let studentArray = participants.split("###");
                        let html = "<ol style='padding-left: 20px;'>";

                        for (let i = 0; i < studentArray.length; i++) {
                            // Split by '||' to get student details: ID, Name, Program, Email, Year
                            let details = studentArray[i].split("||");
                            if (details.length >= 5) {
                                html += "<li style='margin-bottom: 10px;'>" +
                                        "<strong>" + details[1] + "</strong> (" + details[0] + ")<br>" +
                                        "<small>Program: " + details[2] + " | Year: " + details[4] + "<br>" +
                                        "Email: <a href='mailto:" + details[3] + "'>" + details[3] + "</a></small>" +
                                        "</li>";
                            }
                        }
                        html += "</ol>";
                        partBox.innerHTML = html;
                    }
                }
                document.getElementById('detailsModal').style.display = 'block';
            }
        </script>
    </body>
</html>