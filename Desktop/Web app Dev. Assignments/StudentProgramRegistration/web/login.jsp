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
        <title>UniVents - Login</title>
        <link rel="stylesheet" type="text/css" href="style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            /* Use Flexbox to control footer position */
            body {
                display: flex;
                flex-direction: column;
                min-height: 100vh; /* Full screen height */
                margin: 0;
                background-color: #f4f7f6;
            }
            
            /* Thin top header */
            .top-header {
                background-color: #800000;
                color: white;
                padding: 10px 20px;
                text-align: center;
                font-size: 14px;
                letter-spacing: 1px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            
            /* Login form area */
            .main-content {
                flex: 1; /* Main content expands to push footer down */
                display: flex;
                flex-direction: column;
                justify-content: center; /* Center vertically */
                align-items: center; /* Center horizontally */
                padding: 40px 20px;
            }

            .login-wrapper {
                background: white;
                padding: 40px;
                border-radius: 12px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.05);
                width: 100%;
                max-width: 450px; /* Increased width for a better form box size */
                border-top: 5px solid #800000;
                box-sizing: border-box;
            }

            .form-group {
                margin-bottom: 20px;
                text-align: left;
                display: block !important; /* Force form-group to stack neatly */
                width: 100%;
            }
            .form-group label {
                display: block;
                font-weight: bold;
                color: #444;
                margin-bottom: 8px;
            }
            .form-group input {
                width: 100% !important; /* Force input to take full width */
                padding: 12px 15px;
                border: 1px solid #ccc;
                border-radius: 6px;
                box-sizing: border-box;
                font-family: inherit;
            }
            .form-group input:focus {
                border-color: #800000;
                outline: none;
            }

            /* Specific CSS for Password Icon */
            .password-wrapper {
                position: relative;
            }
            .password-wrapper input {
                padding-right: 40px; /* Space for the icon */
            }
            .toggle-password {
                position: absolute;
                right: 12px;
                top: 50%;
                transform: translateY(-50%);
                cursor: pointer;
                color: #888;
                font-size: 16px;
                padding: 5px;
            }
            .toggle-password:hover {
                color: #800000;
            }

            .btn-blue {
                background-color: #800000; /* Theme color: Maroon */
                color: white;
                border: none;
                padding: 14px;
                font-size: 16px;
                font-weight: bold;
                border-radius: 6px;
                cursor: pointer;
                transition: background 0.3s;
            }
            .btn-blue:hover {
                background-color: #5c0000;
            }
            
            /* Error message styling */
            .error-message {
                background-color: #f8d7da;
                color: #721c24;
                padding: 10px;
                border-radius: 5px;
                text-align: center;
                margin-bottom: 20px;
                font-size: 14px;
                border: 1px solid #f5c6cb;
            }
        </style>
    </head>
    <body>
        
        <div class="top-header" style="font-family:times new roman;">
            Welcome to UniVents: Students Program Registration System
        </div>

        <div class="main-content">
            <div style="text-align: center; margin-bottom: 20px;">
                <img src="images/UniVents.png" alt="Univents Logo" style="height: 120px; margin-bottom: 10px;">
                <h1 class="page-title" style="margin: 0; color: #333; font-size: 24px;">Sign In to Your Account</h1>
            </div>

            <div class="login-wrapper">

                <% if ("invalid".equals(request.getParameter("error"))) { %>
                    <div class="error-message">
                        <i class="fas fa-exclamation-circle"></i> Invalid Email or Password!
                    </div>
                <% } %>
                <% if ("unauthorized".equals(request.getParameter("error"))) { %>
                    <div class="error-message">
                        <i class="fas fa-lock"></i> You must login to access that page.
                    </div>
                <% }%>

                <form action="LoginServlet" method="POST" autocomplete="off">
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" name="email" placeholder="Enter your email" required readonly onfocus="this.removeAttribute('readonly');">
                    </div>

                    <div class="form-group">
                        <label>Password</label>
                        <div class="password-wrapper">
                            <input type="password" name="password" id="passwordInput" placeholder="Enter your password" required readonly onfocus="this.removeAttribute('readonly');">
                            <i class="fas fa-eye toggle-password" id="eyeIcon" onclick="togglePassword()" title="Show/Hide Password"></i>
                        </div>
                    </div>

                    <div style="margin-top: 30px;">
                        <button type="submit" class="btn btn-blue" style="width: 100%;">Secure Login</button>
                    </div>
                </form>
            </div>
        </div>

        <jsp:include page="footer.jsp" />

        <script>
            function togglePassword() {
                var pwdInput = document.getElementById("passwordInput");
                var eyeIcon = document.getElementById("eyeIcon");
                
                if (pwdInput.type === "password") {
                    pwdInput.type = "text";
                    eyeIcon.classList.remove("fa-eye");
                    eyeIcon.classList.add("fa-eye-slash"); // Change to eye-slash icon (hidden)
                } else {
                    pwdInput.type = "password";
                    eyeIcon.classList.remove("fa-eye-slash");
                    eyeIcon.classList.add("fa-eye"); // Revert to normal eye icon (visible)
                }
            }
        </script>
    </body>
</html>