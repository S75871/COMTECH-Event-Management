<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, com.model.Event"%>
<%@page import="java.text.SimpleDateFormat"%>
<%
    // Security Check: Only allow members
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
        <title>UniVents - Browse Events</title>
        <link rel="stylesheet" type="text/css" href="style.css">
    </head>
    <body>
        <jsp:include page="navbar.jsp" />

        <div class="main-content">
            <h1 class="page-title">Upcoming UniVents Events</h1>
            <p style="margin: 0 50px 20px; color: #666;">Browse and reserve your seat for upcoming workshops and activities.</p>

            <%-- Success/Error Messages from URL parameters --%>
            <% if ("rsvp_success".equals(request.getParameter("msg"))) { %>
            <div class="alert success"><strong>Success!</strong> Your reservation has been confirmed.</div>
            <% } else if ("already_registered".equals(request.getParameter("error"))) { %>
            <div class="alert error"><strong>Oops!</strong> You are already registered for this event.</div>
            <% } %>

            <div class="event-catalog">
                <%
                    List<Event> events = (List<Event>) request.getAttribute("availableEvents");
                    if (events != null && !events.isEmpty()) {
                        for (Event e : events) {
                            String timeString = (e.getStartTime() != null && e.getEndTime() != null)
                                    ? timeFormatter.format(e.getStartTime()) + " - " + timeFormatter.format(e.getEndTime())
                                    : "TBA";
                %>
                <div class="event-card">
                    <div class="event-header">
                        <h3><%= e.getEventName()%></h3>
                    </div>
                    <div class="event-body">
                        <p><strong>📅 Date:</strong> <%= e.getEventDate()%></p>
                        <p><strong>⏰ Time:</strong> <%= timeString%></p>
                        <p><strong>📍 Venue:</strong> <%= e.getVenue()%></p>
                        <hr>
                        <p><%= e.getDescription() != null ? e.getDescription() : "No details provided."%></p>
                    </div>
                    <div class="event-footer">
                        <%
                            int available = e.getCapacity() - e.getRegisteredCount();
                            if (available > 0) {
                        %>
                        <form action="EventServlet" method="POST">
                            <input type="hidden" name="action" value="rsvp">
                            <input type="hidden" name="eventID" value="<%= e.getEventID()%>">
                            <button type="submit" class="btn btn-green" style="width: 100%;">RSVP Now</button>
                        </form>
                        <% } else { %>
                        <button class="btn btn-gray" disabled style="width:100%">Event Full</button>
                        <% } %>
                    </div>
                </div>
                <%      }
                } else { %>
                <h3 style="text-align:center; color:#888;">No upcoming events at this time.</h3>
                <% } %>
            </div>
        </div>

        <%-- OVERLAP POPUP TRIGGER LOGIC --%>
        <% if ("true".equals(session.getAttribute("showPopup"))) { %>
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                // This forces your popup.jsp to trigger
                var toast = document.getElementById("toastBox");
                if (toast) {
                    toast.style.display = 'block';
                    toast.classList.add("show");
                    setTimeout(function () {
                        toast.style.display = 'none';
                    }, 5000);
                }
            });
        </script>
        <% session.removeAttribute("showPopup"); %>
        <% } %>

        <div id="popup-container">
            <%
                try {
            %>
            <jsp:include page="popup.jsp" />
            <%
                } catch (Exception e) {
                    out.print("");
                }
            %>
        </div>
        <jsp:include page="footer.jsp" />
    </body>
</html>