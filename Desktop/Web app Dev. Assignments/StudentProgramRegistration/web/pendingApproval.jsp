<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.dao.EventDAO" %>
<%@ page import="com.model.Event" %>
<%@ page import="java.util.List" %>
<%@page import="java.text.SimpleDateFormat"%>
<% 
    String role = (String) session.getAttribute("userRole"); 
    // Create a formatter to convert 24-hour SQL time to 12-hour AM/PM format
    SimpleDateFormat timeFormatter = new SimpleDateFormat("hh:mm a");
%>

<!DOCTYPE html>
<html>
    <head>
        <title>UniVents - Event Approval</title>
        <link rel="stylesheet" type="text/css" href="style.css">
      
        <style>
            .btn-approve { background-color: #28a745; color: white; border: none; padding: 6px 10px; border-radius: 4px; cursor: pointer; }
            .btn-reject { background-color: #dc3545; color: white; border: none; padding: 6px 10px; border-radius: 4px; cursor: pointer; }
            .btn-view { background-color: #007bff; color: white; border: none; padding: 6px 10px; border-radius: 4px; cursor: pointer; }
            .modal {
                display:none; position:fixed; top:15%; left:25%; width:50%;
                background:white; padding:25px; border:1px solid #ccc;
                box-shadow:0px 0px 15px rgba(0,0,0,0.3); z-index: 1000; border-radius: 8px;
            }
            .modal p { margin: 8px 0; font-size: 1.05em; }
            
            /* Styles for the Search and Filter Bar */
            .filter-bar {
                display: flex; gap: 15px; margin-bottom: 20px;
                background: #f8f9fa; padding: 15px; border-radius: 8px; border: 1px solid #ddd;
            }
            .filter-bar input, .filter-bar select {
                padding: 8px; border: 1px solid #ccc; border-radius: 4px;
            }
            .filter-bar .search-input { flex-grow: 1; }
        </style>
    </head>
    <body>
        <jsp:include page="navbar.jsp" />
        <div class="main-content">
            <h1>Event Approval Dashboard</h1>

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

            <table id="eventsTable">
                <tr>
                    <th>Event</th><th>Date</th><th>Time</th><th>Venue</th><th>Status</th><th>Action</th>
                </tr>
                <%
                    List<Event> events = (List<Event>) request.getAttribute("pendingEvents");
                    if (events != null && !events.isEmpty()) {
                        for (Event e : events) {
                            // Convert Times to 12-Hour AM/PM
                            String formattedStart = timeFormatter.format(e.getStartTime());
                            String formattedEnd = timeFormatter.format(e.getEndTime());
                            String timeString = formattedStart + " - " + formattedEnd;

                            String safeName = e.getEventName() != null ? e.getEventName().replace("'", "\\'").replace("\"", "&quot;") : "N/A";
                            String safeDesc = e.getDescription() != null ? e.getDescription().replace("\r", " ").replace("\n", " ").replace("'", "\\'").replace("\"", "&quot;") : "No description.";
                            String safeVenue = e.getVenue() != null ? e.getVenue().replace("'", "\\'").replace("\"", "&quot;") : "N/A";
                            String safeComment = e.getAdvisorComment() != null ? e.getAdvisorComment().replace("\r", " ").replace("\n", " ").replace("'", "\\'").replace("\"", "&quot;") : "None";
                %>
                <tr>
                    <td><%= e.getEventName()%></td>
                    <td><%= e.getEventDate()%></td>
                    <td><%= timeString %></td> <td><%= e.getVenue()%></td>
                    <td style="font-weight:bold; color:<%= "Approved".equals(e.getStatus()) ? "green" : ("Rejected".equals(e.getStatus()) ? "red" : "orange")%>">
                        <%= e.getStatus()%>
                    </td>
                    <td>
                        <button type="button" class="btn-view" onclick="viewDetails(
                            '<%= safeName %>', '<%= e.getEventDate() %>', '<%= timeString %>', 
                            '<%= safeVenue %>', '<%= e.getCapacity() %>', '<%= e.getStatus() %>', 
                            '<%= safeComment %>', '<%= safeDesc %>'
                        )">View</button>

                        <% if ("ADVISOR".equals(role)) {%>
                        <button type="button" class="btn-approve" onclick="openModal('<%= e.getEventID()%>', 'Approved')">Approve</button>
                        <button type="button" class="btn-reject" onclick="openModal('<%= e.getEventID()%>', 'Rejected')">Reject</button>
                        <% } %>
                    </td>
                </tr>
                <%      }
                    } else { %>
                <tr><td colspan="6" style="text-align:center;">No events currently require approval.</td></tr>
                <% } %>
            </table>
        </div>

        <div id="detailsModal" class="modal">
            <h2 style="border-bottom: 2px solid #eee; padding-bottom: 10px;">Complete Event Details</h2>
            <p><strong>Event Name:</strong> <span id="detName"></span></p>
            <p><strong>Date:</strong> <span id="detDate"></span></p>
            <p><strong>Time:</strong> <span id="detTime"></span></p>
            <p><strong>Venue:</strong> <span id="detVenue"></span></p>
            <p><strong>Capacity:</strong> <span id="detCapacity"></span> students</p>
            <p><strong>Current Status:</strong> <span id="detStatus" style="font-weight:bold;"></span></p>
            <p><strong>Advisor Feedback:</strong> <span id="detComment"></span></p>
            <hr style="border: 1px solid #eee; margin: 15px 0;">
            <p><strong>Full Description:</strong></p>
            <p id="detDesc" style="background: #f9f9f9; padding: 10px; border-radius: 4px; border: 1px solid #ddd;"></p>
            <div style="text-align: right; margin-top: 20px;">
                <button type="button" class="btn-reject" onclick="document.getElementById('detailsModal').style.display = 'none'">Close Window</button>
            </div>
        </div>

        <div id="approvalModal" class="modal" style="width:30%; left:35%;">
            <h3>Provide Decision</h3>
            <form action="EventServlet" method="POST">
                <input type="hidden" name="action" value="updateStatus">
                <input type="hidden" name="eventID" id="modalEventID">
                <input type="hidden" name="status" id="modalStatus">
                <label>Advisor Comment (Required):</label>
                <textarea name="comment" required style="width:100%; height:80px; margin-top: 10px;"></textarea>
                <br><br>
                <button type="submit" class="btn-approve">Submit Decision</button>
                <button type="button" class="btn-cancel" onclick="document.getElementById('approvalModal').style.display = 'none'">Cancel</button>
            </form>
        </div>

        <script>
            // Modal Logic
            function viewDetails(name, date, time, venue, capacity, status, comment, desc) {
                document.getElementById('detName').innerText = name;
                document.getElementById('detDate').innerText = date;
                document.getElementById('detTime').innerText = time;
                document.getElementById('detVenue').innerText = venue;
                document.getElementById('detCapacity').innerText = capacity;
                document.getElementById('detStatus').innerText = status;
                document.getElementById('detComment').innerText = comment;
                document.getElementById('detDesc').innerText = desc;
                
                let statusEl = document.getElementById('detStatus');
                if(status === 'Approved') statusEl.style.color = 'green';
                else if(status === 'Rejected') statusEl.style.color = 'red';
                else statusEl.style.color = 'orange';

                document.getElementById('detailsModal').style.display = 'block';
            }
            
            function openModal(id, status) {
                document.getElementById('modalEventID').value = id;
                document.getElementById('modalStatus').value = status;
                document.getElementById('approvalModal').style.display = 'block';
            }

            // Client-Side Search and Filter Logic
            function filterTable() {
                // 1. Get inputs and standardize their formatting (lowercase for search, uppercase for time)
                let searchInput = document.getElementById("searchInput").value.toLowerCase().trim();
                let dateInput = document.getElementById("dateFilter").value.trim();
                let timeInput = document.getElementById("timeFilter").value.toUpperCase(); // Force AM/PM to uppercase
                
                let table = document.getElementById("eventsTable");
                let tr = table.getElementsByTagName("tr");

                // 2. Loop through all table rows (skipping the header at index 0)
                for (let i = 1; i < tr.length; i++) {
                    let tdName = tr[i].getElementsByTagName("td")[0];
                    let tdDate = tr[i].getElementsByTagName("td")[1];
                    let tdTime = tr[i].getElementsByTagName("td")[2];
                    let tdVenue = tr[i].getElementsByTagName("td")[3];

                    if (tdName && tdDate && tdTime && tdVenue) {
                        // 3. Extract text and standardize formatting to match the inputs
                        let nameText = (tdName.textContent || tdName.innerText).toLowerCase();
                        let dateText = (tdDate.textContent || tdDate.innerText).trim();
                        // Force the table text to uppercase so 'pm', 'p.m.', and 'PM' all become 'PM'
                        let timeText = (tdTime.textContent || tdTime.innerText).toUpperCase(); 
                        let venueText = (tdVenue.textContent || tdVenue.innerText).toLowerCase();

                        // 4. Check criteria
                        let matchesSearch = nameText.includes(searchInput) || venueText.includes(searchInput);
                        let matchesDate = (dateInput === "") || (dateText === dateInput);
                        let matchesTime = (timeInput === "") || timeText.includes(timeInput);

                        // 5. Show row if it matches ALL filters, hide if not
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
                filterTable(); // Re-run filter to show all rows
            }
        </script>
        
        <jsp:include page="footer.jsp" />
    </body>
</html>



