<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, com.model.Event, java.text.SimpleDateFormat"%>
<%
    String role = (String) session.getAttribute("userRole");
    // This attribute name matches the "eventList" we set in the EventServlet
    List<Event> events = (List<Event>) request.getAttribute("eventList");
    java.text.SimpleDateFormat timeFormatter = new java.text.SimpleDateFormat("hh:mm a");
%>
<!DOCTYPE html>
<html>
    <head>
        <title>UniVents - Reservations</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"> <link rel="stylesheet" type="text/css" href="style.css">
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
            
            /* Base Styles for Search and Filter Bar */
            .filter-bar {
                display: flex; 
                gap: 15px; 
                margin-bottom: 20px;
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

            /* Responsive Table Container */
            .table-container {
                padding: 0 50px;
                overflow-x: auto; /* Allows horizontal scrolling on small devices */
                width: 100%;
                box-sizing: border-box;
            }

            /* Base Styles for Modal */
            #detailsModal {
                display: none; 
                position: fixed; 
                top: 50%; 
                left: 50%; 
                transform: translate(-50%, -50%); /* Perfectly centers the modal */
                width: 50%; 
                background: white; 
                padding: 20px; 
                border-radius: 8px; 
                box-shadow: 0 0 15px rgba(0,0,0,0.3); 
                z-index: 1000;
                max-height: 90vh;
                overflow-y: auto;
            }

            /* =========================================
               MEDIA QUERIES (Mobile Devices)
               ========================================= */
            @media (max-width: 768px) {
                /* Stack filter bar inputs vertically */
                .filter-bar {
                    flex-direction: column;
                }
                .filter-bar input, .filter-bar select, .filter-bar button {
                    width: 100%;
                    box-sizing: border-box;
                }
                
                /* Reduce table padding for mobile screens */
                .table-container {
                    padding: 0 15px;
                }

                /* Expand modal to fit mobile screen */
                #detailsModal {
                    width: 90%;
                    padding: 15px;
                }
            }
        </style>
    </head>
    <body>
        <jsp:include page="navbar.jsp" />

        <div class="main-content">
            <h1 class="page-title">Reservations Management</h1>
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
            
            <div class="table-container">
                <table id="eventsTable" style="width: 100%; border-collapse: collapse;">
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
                                            '<%= e.getParticipantNames() != null ? e.getParticipantNames().replace("'", "\\'") : ""%>')">View</button>

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
                    <tr><td colspan="7" style="text-align:center; padding: 20px;">No reservations found.</td></tr>
                    <% } %>
                </table>
            </div>
        </div>

        <div id="detailsModal">
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
            // Removed trailing comma from parameters
            function viewDetails(name, ajks, desc, participants) {
                document.getElementById('modTitle').innerText = name;
                document.getElementById('modAJKs').innerText = ajks;
                document.getElementById('modDesc').innerText = desc; // Removed duplicate line

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
            
function filterTable() {
    let searchInput = document.getElementById("searchInput").value.toLowerCase();
    let dateFilter = document.getElementById("dateFilter").value; 
    let timeFilter = document.getElementById("timeFilter").value.toUpperCase(); 
    let table = document.getElementById("eventsTable");
    let tr = table.getElementsByTagName("tr");

    for (let i = 1; i < tr.length; i++) {
        if (tr[i].getElementsByTagName("td").length === 1) {
            continue; 
        }

        let tdName = tr[i].getElementsByTagName("td")[0]; 
        let tdTime = tr[i].getElementsByTagName("td")[1]; 
        let tdDate = tr[i].getElementsByTagName("td")[3];  
        let tdVenue = tr[i].getElementsByTagName("td")[4]; 

        if (tdName && tdTime && tdDate && tdVenue) {
            let nameValue = tdName.textContent || tdName.innerText;
            let venueValue = tdVenue.textContent || tdVenue.innerText;
            let timeValue = tdTime.textContent || tdTime.innerText;
            let dateValue = tdDate.textContent || tdDate.innerText;

            let matchSearch = (nameValue.toLowerCase().indexOf(searchInput) > -1) || 
                              (venueValue.toLowerCase().indexOf(searchInput) > -1);

            let matchDate = (dateFilter === "") || (dateValue.includes(dateFilter));

            let matchTime = (timeFilter === "") || (timeValue.includes(timeFilter));

            if (matchSearch && matchDate && matchTime) {
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
        <jsp:include page="footer.jsp" />
    </body>
</html>