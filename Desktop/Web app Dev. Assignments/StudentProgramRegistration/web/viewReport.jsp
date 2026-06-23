<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>UniVents - Event Summary Report</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

    <style>
    /* Global Container */
    .container { padding: 40px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f6; min-height: 100vh; }

    /* Header Row */
    .report-header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
    .report-title { font-size: 24px; font-weight: bold; color: #2c3e50; }
    
    /* Summary Boxes */
    .summary-boxes { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }
    .box { background: #ffffff; padding: 20px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); 
           text-align: center; font-weight: bold; color: #34495e; border-left: 5px solid #800000; }

    /* Section Cards */
    .section-card { background: #ffffff; padding: 25px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 30px; }
    
    /* Table Styling */
    table { width: 100%; border-collapse: collapse; margin-top: 15px; }
    th { background-color: #800000; color: white; padding: 15px; text-align: center; }
    td { padding: 12px; border-bottom: 1px solid #eee; text-align: center; color: #555; }
    tr:hover { background-color: #f9f9f9; }

    /* Chart Box */
    .chart-box { height: 400px; width: 100%; margin-top: 20px; }

    /* Buttons */
    .btn-red { background-color: #800000; color: white; border: none; padding: 10px 20px; 
               border-radius: 5px; cursor: pointer; font-weight: bold; }
    .btn-red:hover { background-color: #a00000; }

    .no-data { text-align: center; padding: 40px; color: #999; font-style: italic; }
</style>
    <jsp:include page="navbar.jsp" />

    <div class="container">
        <%
            List<Map<String, Object>> reportData = (List<Map<String, Object>>) request.getAttribute("reportData");
            String viewMode = (String) request.getAttribute("viewMode");
            String displayMonth = (String) request.getAttribute("selectedMonthName");
            String displayYear = (String) request.getAttribute("selectedYear");

            if (viewMode == null) viewMode = "both";
            if (displayMonth == null) displayMonth = "January";
            if (displayYear == null) displayYear = "2026";

            int totalEvents = (reportData != null) ? reportData.size() : 0;
            int totalActual = 0;
            int totalTarget = 0;
            if(reportData != null) {
                for(Map m : reportData) {
                    totalActual += (int)m.get("actualPart");
                    totalTarget += (int)m.get("totalPart");
                }
            }
            double overallRate = (totalTarget > 0) ? ((double)totalActual/totalTarget)*100 : 0;
        %>

        <div class="report-header-row">
            <div class="report-title">📊 Monthly Event Summary: <%= displayMonth %> <%= displayYear %></div>
            <button class="btn-red" onclick="window.print()">🖨️ Download PDF</button>
        </div>

        <div class="summary-boxes">
            <div class="box">📋 Total Events: <%= totalEvents %></div>
            <div class="box">👥 Total Attendance: <%= totalActual %></div>
            <div class="box">📈 Attendance Rate: <%= String.format("%.2f", overallRate) %>%</div>
        </div>

        <% if (viewMode.equals("table") || viewMode.equals("both")) { %>
        <div class="section-card">
            <h3>1. Detailed Event Statistics</h3>
            <table>
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Event Name</th>
                        <th>Venue</th>
                        <th>Time</th>
                        <th>Category</th>
                        <th>Level</th>
                        <th>Target</th>
                        <th>Actual</th>
                        <th>Attendance Rate</th>
                        <th>Avg Rating</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (reportData != null && !reportData.isEmpty()) { 
                        for (Map<String, Object> row : reportData) { %>
                        <tr>
                            <td><%= row.get("eventDate") %></td>
                            <td style="text-align: left; font-weight: bold;"><%= row.get("eventName") %></td>
                            <td><%= row.get("venue") %></td>
                            <td><%= row.get("time") %></td>
                            <td><%= row.get("category") %></td>
                            <td><%= row.get("level") %></td>
                            <td><%= row.get("totalPart") %></td>
                            <td><%= row.get("actualPart") %></td>
                            <td style="color: #0d47a1; font-weight: bold;"><%= String.format("%.2f", (double)row.get("attendanceRate")) %>%</td>
                            <td style="color: #f39c12; font-weight: bold;">
                                <%= String.format("%.1f", (double)row.get("avgScore")) %> ⭐
                            </td>
                        </tr>
                    <% } } else { %>
                        <tr><td colspan="10" class="no-data">No records found for the selected period.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>

        <% if (viewMode.equals("graph") || viewMode.equals("both")) { 
            if (reportData != null && !reportData.isEmpty()) { %>
        <div class="section-card">
            <h3>2. Metrics Analysis Visualization</h3>
            <div class="chart-box">
                <canvas id="univentsChart"></canvas>
            </div>
        </div>
        <% } else { %>
        <div class="section-card">
            <h3>2. Metrics Analysis Visualization</h3>
            <div class="no-data">No data available to display chart.</div>
        </div>
        <% } } %>

    </div>

    <jsp:include page="footer.jsp" />

    <script>
        const labels = [];
        const targetData = [];
        const actualData = [];
        const scoreData = [];

        <% if (reportData != null && !reportData.isEmpty()) { 
            for (Map<String, Object> row : reportData) { %>
                labels.push('<%= row.get("eventName").toString().replace("'", "\\'") %>');
                targetData.push(<%= row.get("totalPart") %>);
                actualData.push(<%= row.get("actualPart") %>);
                scoreData.push(<%= row.get("avgScore") %>);
        <% } } %>

        <% if (reportData != null && !reportData.isEmpty()) { %>
        const ctx = document.getElementById('univentsChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Target Participant',
                        data: targetData,
                        borderColor: '#2ecc71',
                        backgroundColor: 'transparent',
                        borderWidth: 3,
                        pointRadius: 5,
                        tension: 0.3
                    },
                    {
                        label: 'Actual Participant',
                        data: actualData,
                        borderColor: '#0d47a1',
                        backgroundColor: 'rgba(13, 71, 161, 0.1)',
                        borderWidth: 3,
                        pointRadius: 5,
                        fill: true,
                        tension: 0.3
                    },
                    {
                        label: 'Average Feedback Score',
                        data: scoreData,
                        borderColor: '#9b59b6',
                        backgroundColor: 'transparent',
                        borderWidth: 3,
                        pointRadius: 5,
                        tension: 0.3,
                        yAxisID: 'y1'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: { 
                        beginAtZero: true, 
                        title: { 
                            display: true, 
                            text: 'Participants Count' 
                        } 
                    },
                    y1: { 
                        position: 'right', 
                        min: 0, 
                        max: 5, 
                        grid: {
                            drawOnChartArea: false 
                        }, 
                        title: { 
                            display: true, 
                            text: 'Rating Score (1-5)' 
                        } 
                    }
                },
                plugins: {
                    legend: { 
                        position: 'top' 
                    }
                }
            }
        });
        <% } %>
    </script>

</body>
</html>