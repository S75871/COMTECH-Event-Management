<%-- 
    Document   : generateReportForm
    Created on : 17 Jun 2026, 4:13:30 pm
    Author     : Ainaa Nadhirah
--%>

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
        <title>COMTECH - Generate Report</title>
        <link rel="stylesheet" type="text/css" href="style.css">
        <style>
            .container { 
                padding: 50px 20px; 
            }

            .form-container { 
                background-color: white; 
                padding: 40px; 
                border-radius: 15px; 
                box-shadow: 0 4px 12px rgba(0,0,0,0.1); 
                max-width: 450px; 
                margin: auto; 
                border-top: 5px solid #000080;
            }

            h3 { 
                color: #0d47a1; 
                margin-top: 0; 
                text-align: center;
                font-size: 24px;
                margin-bottom: 10px;
            }
            
            .subtitle {
                text-align: center;
                color: #666;
                font-size: 14px;
                margin-bottom: 25px;
            }

            label { 
                display: block; 
                margin: 15px 0 8px; 
                font-weight: bold; 
                color: #333; 
                font-size: 14px;
            }

            select { 
                width: 100%; 
                padding: 12px; 
                border-radius: 8px; 
                border: 1px solid #ccc; 
                background-color: #f9f9f9;
                font-size: 14px;
                box-sizing: border-box;
            }
            
            select:focus {
                border-color: #0d47a1;
                outline: none;
                box-shadow: 0 0 5px rgba(13, 71, 161, 0.3);
            }

            button { 
                width: 100%; 
                padding: 14px; 
                margin-top: 30px; 
                cursor: pointer; 
                font-weight: bold; 
                background-color: #0d47a1; 
                color: white; 
                border: none; 
                border-radius: 8px; 
                font-size: 16px;
                transition: 0.3s; 
            }

            button:hover {
                background-color: #1565c0; 
                box-shadow: 0 4px 8px rgba(0,0,0,0.2);
                transform: translateY(-2px);
            }
            
            button:active {
                transform: translateY(0);
            }
            
            .btn-back {
                display: block;
                text-align: center;
                margin-top: 15px;
                color: #757575;
                text-decoration: none;
                font-size: 14px;
            }
            
            .btn-back:hover {
                color: #0d47a1;
                text-decoration: underline;
            }
            
            .alert-info {
                background-color: #e3f2fd;
                color: #0d47a1;
                padding: 12px 20px;
                border-radius: 6px;
                margin-bottom: 20px;
                border-left: 4px solid #0d47a1;
                font-size: 14px;
            }
        </style>
    </head>
    <body>

        <jsp:include page="navbar.jsp" />

        <div class="container">
            <div class="form-container">
                <h3>📊 Generate Report</h3>
                <p class="subtitle">Select month and year to generate event summary report</p>
                
                <%
                    String msg = request.getParameter("msg");
                    if ("success".equals(msg)) {
                %>
                <div class="alert-info">✅ Report generated successfully!</div>
                <% } %>
                
                <form action="ReportFeedbackServlet" method="GET">
                    <input type="hidden" name="action" value="generateReport">
                    
                    <label for="viewMode">📋 View Mode:</label>
                    <select id="viewMode" name="viewMode" required>
                        <option value="both">Both (Table & Graph)</option>
                        <option value="table">Table View Only</option>
                        <option value="graph">Graph Analysis Only</option>
                    </select>
                    
                    <label for="month">📅 Month:</label>
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
                    
                    <label for="year">📆 Year:</label>
                    <select id="year" name="year">
                        <option value="2024">2024</option>
                        <option value="2025">2025</option>
                        <option value="2026" selected>2026</option>
                        <option value="2027">2027</option>
                        <option value="2028">2028</option>
                    </select>
                    
                    <button type="submit">🚀 Generate Report</button>
                </form>
                
                <a href="home.jsp" class="btn-back">⬅ Back to Dashboard</a>
            </div>
        </div>

        <jsp:include page="footer.jsp" />
    </body>
</html>