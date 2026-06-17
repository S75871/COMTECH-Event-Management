<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Force the browser to never cache the login page
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); 
    response.setHeader("Pragma", "no-cache"); 
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
    <head>
        <title>COMTECH - Login</title>
        <link rel="stylesheet" type="text/css" href="style.css">
    </head>
    <body>

        <div class="main-content">

            <div style="text-align: center; margin-top: 80px;">
                <img src="images/COMTECH.png" alt="COMTECH Logo" style="height: 100px; margin-bottom: 10px;">
                <h1 class="page-title" style="margin-top: 0;">System Login</h1>
            </div>

            <div class="form-container" style="max-width: 500px; margin: 0 auto;">

                <% if ("invalid".equals(request.getParameter("error"))) { %>
                <p style="color: red; text-align: center; font-weight: bold;">Invalid Email or Password!</p>
                <% } %>
                <% if ("unauthorized".equals(request.getParameter("error"))) { %>
                <p style="color: red; text-align: center; font-weight: bold;">You must login to access that page.</p>
                <% }%>

                <form action="LoginServlet" method="POST" autocomplete="off">
                    <div class="form-group">
                        <label style="width: 100px;">Email :</label>
                        <input type="email" name="email" required readonly onfocus="this.removeAttribute('readonly');">
                    </div>

                    <div class="form-group">
                        <label>Password:</label>
                        <div class="password-wrapper">
                            <input type="password" name="password" id="passwordInput" required readonly onfocus="this.removeAttribute('readonly');" >
                            <span class="toggle-password" onclick="togglePassword()">show/hide️</span>
                        </div>
                    </div>

                    <div class="btn-group" style="padding-left: 0; justify-content: center;">
                        <button type="submit" class="btn btn-blue" style="width: 100%;">Login</button>
                    </div>
                </form>
            </div>

        </div>

        <jsp:include page="footer.jsp" />
        <script>
            function togglePassword() {
                var x = document.getElementById("passwordInput");
                if (x.type === "password") {
                    x.type = "text";
                } else {
                    x.type = "password";
                }
            }

        </script>
    </body>
</html>