<%-- popup.jsp --%>
<div class="toast-container" id="toastBox">
    <%
        // 1. Check Session Attributes (for Overlap logic)
        String showPopup = (String) session.getAttribute("showPopup");
        // 2. Check URL Parameters (for standard success/error)
        String msg = request.getParameter("msg");
        String error = request.getParameter("error");

        String cssClass = "";
        String text = "";

        if ("true".equals(showPopup)) {
            cssClass = "toast error";
            text = "Event time overlaps with an existing reservation!";
            session.removeAttribute("showPopup");
        } else if (msg != null || error != null) {
            cssClass = (msg != null) ? "toast success" : "toast error";
            text = (msg != null) ? "Action Successful!" : "Action Failed!";
            
            if ("rsvp_success".equals(msg)) text = "Reservation confirmed!";
            else if ("already_registered".equals(error)) text = "You are already registered.";
            else if ("unauthorized".equals(error)) text = "Please log in first.";
        }

        if (!cssClass.isEmpty()) {
    %>
    <div class="<%= cssClass %> show"><%= text %></div>
    <% } %>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        var toastBox = document.getElementById("toastBox");
        // Check if there is an actual message to show
        if (toastBox && toastBox.querySelector('.toast')) {
            var toast = toastBox.querySelector('.toast');
            // The class 'show' is already applied by the JSP if needed, 
            // but we add a timeout to remove it for animation
            setTimeout(function () {
                toast.classList.remove("show");
            }, 3500);
        }
    });
</script>