<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>UniVents - Create Event</title>
        <link rel="stylesheet" type="text/css" href="style.css">
    </head>
    <body>
        <div class="main-content">
            <jsp:include page="navbar.jsp" />

            <h1 class="page-title">Create New Event</h1>

            <% if ("true".equals(request.getParameter("error"))) { %>
            <p style="color: red; margin-left: 50px;">Failed to create event. Please try again.</p>
            <% }%>

            <div class="form-container">
                <form action="EventServlet" method="POST">
                    <input type="hidden" name="action" value="create">

                    <div class="grid-form">
                        <div class="form-group">
                            <label>Event Name:</label>
                            <input type="text" name="eventName" required>
                        </div>

                        <div class="form-group">
                            <label>Date:</label>
                            <input type="date" name="eventDate" required>
                        </div>

                        <div class="form-group">
                            <label>Start Time:</label>
                            <input type="time" name="startTime" required>
                        </div>

                        <div class="form-group">
                            <label>End Time:</label>
                            <input type="time" name="endTime" required>
                        </div>

                        <div class="form-group">
                            <label>Venue:</label>
                            <input type="text" name="venue" required>
                        </div>

                        <div class="form-group">
                            <label>Participant Capacity:</label>
                            <input type="number" name="capacity" min="1" required>
                        </div>

                        <div class="form-group">
                            <label>Event AJKs (Committee):</label>
                            <input type="text" name="eventAJKs" placeholder="e.g., Ali (Director), Siti (Logistics)" required>
                        </div>

                        <div class="form-group full-width">
                            <label>Description:</label>
                            <textarea name="description" rows="4" required style="width: 100%;"></textarea>
                        </div>
                    </div>

                    <div style="margin-top: 20px;">
                        <button type="submit" class="btn btn-blue">Submit</button>
                        <a href="home.jsp" class="btn btn-cancel">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
        <%
            String showPopup = (String) session.getAttribute("showPopup");
            if ("true".equals(showPopup)) {
        %>
        <jsp:include page="popUp.jsp" />

        <script>
            // Trigger popup open function here
            openPopup();
        </script>
        <%
                // CRITICAL: Remove the flag so it doesn't show up again on refresh
                session.removeAttribute("showPopup");
            }
        %>
        <jsp:include page="footer.jsp" />
    </body>
</html>