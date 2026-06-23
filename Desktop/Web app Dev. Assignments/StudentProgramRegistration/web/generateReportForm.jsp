<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Authorization: Only ADVISOR or COMMITTEE can access reports
    String role = (String) session.getAttribute("userRole");
    if (!"ADVISOR".equals(role) && !"COMMITTEE".equals(role)) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>UniVents - Generate Report</title>
        <link rel="stylesheet" type="text/css" href="style.css">

        <style>
            body {
                background-color: #f4f7f6; /* Subtle light background to make the form pop */
                margin: 0;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .container {
                display: flex;
                justify-content: center;
                align-items: center;
                padding: 40px 20px;
            }
            .form-container {
                background: #ffffff;
                width: 100%;
                max-width: 450px;
                padding: 35px 40px;
                border-radius: 12px;
                box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08); /* Soft drop shadow */
            }

            /* --- Typography --- */
            .form-container h3 {
                color: #1A365D; /* Professional dark blue */
                margin-top: 0;
                margin-bottom: 5px;
                text-align: center;
                font-size: 26px;
            }
            .subtitle {
                text-align: center;
                color: #666;
                margin-bottom: 25px;
                font-size: 14px;
            }

            /* --- Alerts --- */
            .alert-info {
                background-color: #d4edda;
                color: #155724;
                padding: 12px;
                border-radius: 6px;
                margin-bottom: 20px;
                text-align: center;
                font-weight: 600;
                border: 1px solid #c3e6cb;
            }

            /* --- Form Elements --- */
            label {
                display: block;
                font-weight: 600;
                color: #444;
                margin-bottom: 8px;
                margin-top: 18px;
                font-size: 14px;
            }
            select {
                width: 100%;
                padding: 12px 15px;
                border: 1px solid #ccc;
                border-radius: 6px;
                font-size: 15px;
                box-sizing: border-box;
                appearance: none; /* Removes default browser dropdown arrow */
                background-color: #f9f9f9;
                /* Custom modern dropdown arrow */
                background-image: url('data:image/svg+xml;utf8,<svg fill="%23666" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="M7 10l5 5 5-5z"/><path d="M0 0h24v24H0z" fill="none"/></svg>');
                background-repeat: no-repeat;
                background-position: right 10px center;
                transition: all 0.3s ease;
            }
            select:focus {
                border-color: #3498db;
                outline: none;
                background-color: #ffffff;
                box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.2);
            }

            /* --- Buttons & Links --- */
            button[type="submit"] {
                width: 100%;
                padding: 14px;
                background-color: maroon;
                color: white;
                border: none;
                border-radius: 6px;
                font-size: 16px;
                font-weight: bold;
                cursor: pointer;
                margin-top: 30px;
                transition: background 0.3s ease, transform 0.1s;
            }
            button[type="submit"]:hover {
                background-color: #2980b9;
            }
            button[type="submit"]:active {
                transform: scale(0.98); /* Slight click effect */
            }

            .btn-back {
                display: block;
                text-align: center;
                margin-top: 25px;
                color: #757575;
                text-decoration: none;
                font-size: 14px;
                transition: color 0.3s;
                font-weight: 500;
            }
            .btn-back:hover {
                color: #333;
                text-decoration: underline;
            }
            .container {
                width: 80%;
                margin: auto;
                display: flex; 
                gap: 20px;
            }

            .box {
                width: 50%; 
            }

         
            @media screen and (max-width: 768px) {

                .container {
                    width: 95%; 
                    flex-direction: column;
                }

                .box {
                    width: 100%; 
                    margin-bottom: 15px;
                }

                h1, h2, h3 {
                    font-size: 1.5rem;
                }
            }
        </style>
    </head>
    <body>

        <jsp:include page="navbar.jsp" />

        <div class="container">
            <div class="form-container">
                <h3>Generate Report</h3>
                <p class="subtitle">Select month and year to generate event summary report</p>

                <%
                    String msg = request.getParameter("msg");
                    if ("success".equals(msg)) {
                %>
                <div class="alert-info">Report generated successfully!</div>
                <% }%>

                <form action="ReportFeedbackServlet" method="GET">
                    <input type="hidden" name="action" value="generateReport">

                    <label for="viewMode">View Mode:</label>
                    <select id="viewMode" name="viewMode" required>
                        <option value="both">Both (Table & Graph)</option>
                        <option value="table">Table View Only</option>
                        <option value="graph">Graph Analysis Only</option>
                    </select>

                    <label for="month">Month:</label>
                    <select id="month" name="month">
                        <option value="01">January</option>
                        <option value="02">February</option>
                        <option value="03">March</option>
                        <option value="04">April</option>
                        <option value="05">May</option>
                        <option value="06">June</option>
                        <option value="07">July</option>
                        <option value="08">August</option>
                        <option value="09">September</option>
                        <option value="10">October</option>
                        <option value="11">November</option>
                        <option value="12">December</option>
                    </select>

                    <label for="year">Year:</label>
                    <select id="year" name="year">
                        <option value="2024">2024</option>
                        <option value="2025">2025</option>
                        <option value="2026" selected>2026</option>
                        <option value="2027">2027</option>
                        <option value="2028">2028</option>
                    </select>

                    <button type="submit">Generate Report</button>
                </form>

                <a href="home.jsp" class="btn-back">⬅ Back to Dashboard</a>
            </div>
        </div>

        <jsp:include page="footer.jsp" />
    </body>
</html>