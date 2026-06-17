<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.lab.model.ClubMember"%>
<%@page import="com.lab.model.ClubCommittee"%>

<%
    // =========================================================================
    // CACHE CONTROL
    // Prevents the browser from caching the page so the Advisor always sees 
    // the most up-to-date member list immediately after adding or deleting.
    // =========================================================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>

<!DOCTYPE html>
<html>
<head>
    <title>COMTECH - Manage Members</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>

    <div class="main-content">

        <jsp:include page="navbar.jsp" />

        <h1 class="page-title">Manage Club Members</h1>

        <% if ("added".equals(request.getParameter("msg"))) { %>
            <p style="color: green; margin-left: 50px; font-weight: bold;">Member successfully added to the system.</p>
        <% } %>
        
        <% if ("deleted".equals(request.getParameter("msg"))) { %>
            <p style="color: red; margin-left: 50px; font-weight: bold;">Member account permanently deleted.</p>
        <% } %>


        <div class="form-container">
            <h3 style="color: var(--primary-blue); margin-top: 0;">Add New Member</h3>
            <form action="MemberServlet" method="POST">
                <input type="hidden" name="action" value="add">

                <div class="grid-form">
                    <div class="form-group">
                        <label>Student ID (Matric No):</label>
                        <input type="text" name="memberID" required placeholder="e.g. UK12345">
                    </div>
                    <div class="form-group">
                        <label>Full Name:</label>
                        <input type="text" name="name" required>
                    </div>
                    <div class="form-group">
                        <label>Email:</label>
                        <input type="email" name="email" required>
                    </div>
                    <div class="form-group">
                        <label>Password:</label>
                        <input type="text" name="password" required value="Comtech123!">
                    </div>
                    <div class="form-group">
                        <label>Phone Number:</label>
                        <input type="text" name="phoneNo" required>
                    </div>

                    <div class="form-group">
                        <label>Assign Role:</label>
                        <select name="role" required>
                            <option value="MEMBER">Club Member (Student)</option>
                            <option value="COMMITTEE">Club Committee (AJK)</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Position (For AJK):</label>
                        <input type="text" name="position" placeholder="e.g. Secretary (Leave blank if Member)">
                    </div>

                    <div class="form-group full-width">
                        <label>Program:</label>
                        <select name="program" required>
                            <option value="Sarjana Muda Sains Komputer (Kejuruteraan Perisian) dengan Kepujian">Sarjana Muda Sains Komputer (Kejuruteraan Perisian) dengan Kepujian</option>
                            <option value="Sarjana Muda Sains Komputer dengan Informatik Maritim (Kepujian)">Sarjana Muda Sains Komputer dengan Informatik Maritim (Kepujian)</option>
                            <option value="Sarjana Muda Sains Komputer (Komputeran Mudah Alih) dengan Kepujian">Sarjana Muda Sains Komputer (Komputeran Mudah Alih) dengan Kepujian</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Year of Study:</label>
                        <input type="number" name="year" min="1" max="4" value="1" required>
                    </div>
                </div>

                <div style="margin-top: 20px;">
                    <button type="submit" class="btn btn-green">+ Add Member</button>
                </div>
            </form>
        </div>


        <div class="form-container" style="margin-top: 20px;">
            <h3 style="color: var(--primary-blue); margin-top: 0;">Bulk Import Members (CSV)</h3>

            <form action="MemberServlet" method="POST" enctype="multipart/form-data" style="display: flex; gap: 15px; align-items: center;">
                <input type="hidden" name="action" value="import">
                <input type="file" name="file" accept=".csv" required style="padding: 10px; border: 1px dashed var(--primary-blue); border-radius: 6px; flex: 1;">
                <button type="submit" class="btn btn-blue">Upload & Import</button>
            </form>
            <p style="color: gray; font-size: 12px; margin-top: 10px;">
                *Upload a CSV file. Expected columns: <b>Name, Email, Phone, Role (MEMBER/COMMITTEE), Program/Position, Year, Student ID</b>
            </p>
        </div>


        <div class="form-container">
            <h3 style="color: #28a745; margin-top: 0;">Committee Roster (AJK)</h3>
            <table>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Position</th>
                    <th>Year</th>
                    <th>Role</th>
                    <th>Action</th>
                </tr>
                <%
                    // Fetch specifically the committee list passed from the Servlet
                    List<ClubCommittee> committeeList = (List<ClubCommittee>) request.getAttribute("committeeList");

                    // Check if the list is valid and contains data
                    if (committeeList != null && !committeeList.isEmpty()) {
                        for (ClubCommittee c : committeeList) {
                %>
                <tr>
                    <td><strong><%= c.getCommitteeID()%></strong></td>
                    <td><%= c.getName()%></td>
                    <td><%= c.getEmail()%></td>
                    <td><%= c.getPosition()%></td> 
                    <td>Year <%= c.getYear()%></td>
                    <td>
                        <span style="background: #28a745; color: white; padding: 4px 8px; border-radius: 4px; font-size: 0.85em; font-weight: bold;">COMMITTEE</span>
                    </td>
                    <td>
                        <form action="MemberServlet" method="POST" onsubmit="return confirm('Are you sure you want to delete <%= c.getName().replace("'", "\\'") %>?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="memberId" value="<%= c.getCommitteeID()%>">
                            <button type="submit" class="btn btn-red" style="padding: 5px 10px; font-size: 12px;">Remove</button>
                        </form>
                    </td>
                </tr>
                <%
                        } // End loop
                    } else {
                %>
                <tr><td colspan="7" style="text-align: center; color: #666;">No committee members found in the system.</td></tr>
                <% } %>
            </table>
        </div>


        <div class="form-container">
            <h3 style="color: #17a2b8; margin-top: 0;">Standard Member Roster</h3>
            <table>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Program</th>
                    <th>Year</th>
                    <th>Role</th>
                    <th>Action</th>
                </tr>
                <%
                    // Fetch specifically the standard member list passed from the Servlet
                    List<ClubMember> memberList = (List<ClubMember>) request.getAttribute("memberList");

                    // Check if the list is valid and contains data
                    if (memberList != null && !memberList.isEmpty()) {
                        for (ClubMember m : memberList) {
                %>
                <tr>
                    <td><strong><%= m.getMemberID()%></strong></td>
                    <td><%= m.getName()%></td>
                    <td><%= m.getEmail()%></td>
                    <td><%= m.getProgram()%></td>
                    <td>Year <%= m.getYear()%></td>
                    <td>
                        <span style="background: #17a2b8; color: white; padding: 4px 8px; border-radius: 4px; font-size: 0.85em; font-weight: bold;">MEMBER</span>
                    </td>
                    <td>
                        <form action="MemberServlet" method="POST" onsubmit="return confirm('Are you sure you want to delete <%= m.getName().replace("'", "\\'") %>?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="memberId" value="<%= m.getMemberID()%>">
                            <button type="submit" class="btn btn-red" style="padding: 5px 10px; font-size: 12px;">Remove</button>
                        </form>
                    </td>
                </tr>
                <%
                        } // End loop
                    } else {
                %>
                <tr><td colspan="7" style="text-align: center; color: #666;">No standard members found in the system.</td></tr>
                <% } %>
            </table>
        </div>

    </div> 
    
    <jsp:include page="footer.jsp" />

</body>
</html>