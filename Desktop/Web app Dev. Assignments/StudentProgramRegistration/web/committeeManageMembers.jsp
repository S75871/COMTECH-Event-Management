<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <title>UniVents - Manage Club Members</title>
        <link rel="stylesheet" href="style.css">

        <script>
            function filterTable() {
                let textFilter = document.getElementById("searchInput").value.toUpperCase();
                let yearFilter = document.getElementById("yearFilter").value;
                let rows = document.getElementsByClassName("memberRow");

                let masterCheckbox = document.getElementById("selectAllMaster");
                if (masterCheckbox)
                    masterCheckbox.checked = false;

                for (let i = 0; i < rows.length; i++) {
                    let cells = rows[i].getElementsByTagName("td");

                    if (cells.length > 5) {
                        let id = cells[1].innerText.toUpperCase();
                        let name = cells[2].innerText.toUpperCase();
                        let year = cells[5].innerText.toUpperCase();

                        let matchesText = (id.indexOf(textFilter) > -1 || name.indexOf(textFilter) > -1);
                        let matchesYear = (yearFilter === "ALL" || year === yearFilter);

                        if (matchesText && matchesYear) {
                            rows[i].style.display = "";
                        } else {
                            rows[i].style.display = "none";
                        }
                    }
                }
            }

            function toggleSelectAll(source) {
                let checkboxes = document.getElementsByName('selectedMembers');
                for (let i = 0; i < checkboxes.length; i++) {
                    if (checkboxes[i].closest('tr').style.display !== 'none') {
                        checkboxes[i].checked = source.checked;
                    }
                }
            }
        </script>
    </head>
    <body>
        <jsp:include page="navbar.jsp" />

        <div class="container" style="min-height: 80vh; padding: 20px;">
            <h2 style="color: #0033a0;">Club Members Directory</h2>
            <p>Review the list or remove members from the directory.</p>

            <c:if test="${param.msg == 'deleted' || param.msg == 'bulkDeleted'}">
                <div style="background-color: #d4edda; color: #155724; padding: 10px; border-radius: 5px; margin-bottom: 15px;">
                    <strong>Successfully removed selected member(s).</strong>
                </div>
            </c:if>
            <c:if test="${param.error == 'noneSelected'}">
                <div style="background-color: #f8d7da; color: #721c24; padding: 10px; border-radius: 5px; margin-bottom: 15px;">
                    <strong>Error: You must select at least one member first!</strong>
                </div>
            </c:if>

            <div style="display: flex; gap: 15px; margin-bottom: 20px;">
                <input type="text" id="searchInput" onkeyup="filterTable()" placeholder="🔍 Search by Name or ID..." style="flex: 1; padding: 12px; border: 2px solid #0033a0; border-radius: 5px; font-size: 16px;">

                <select id="yearFilter" onchange="filterTable()" style="padding: 12px; border: 2px solid #0033a0; border-radius: 5px; font-size: 16px; background-color: white; color: #0033a0; font-weight: bold; cursor: pointer;">
                    <option value="ALL">All Years</option>
                    <option value="1">Year 1</option>
                    <option value="2">Year 2</option>
                    <option value="3">Year 3</option>
                    <option value="4">Year 4</option>
                </select>
            </div>

            <form action="ManageMembersServlet" method="POST">
                <div style="margin-bottom: 15px;">
                    <button type="submit" name="action" value="bulkDelete" onclick="return confirm('Are you sure you want to permanently delete ALL selected members?');" style="background-color: #dc3545; color: white; padding: 10px 20px; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">🗑️ Remove Selected</button>
                </div>

                <table class="table" border="1" style="width: 100%; text-align: left; border-collapse: collapse; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
                    <tr style="background-color: #0033a0; color: white;">
                        <th style="padding: 15px; text-align: center;"><input type="checkbox" id="selectAllMaster" onclick="toggleSelectAll(this)" style="transform: scale(1.5); cursor: pointer;"></th>
                        <th style="padding: 15px;">Member ID</th>
                        <th style="padding: 15px;">Name</th>
                        <th style="padding: 15px;">Email</th>
                        <th style="padding: 15px;">Program</th>
                        <th style="padding: 15px; text-align: center;">Year</th>
                    </tr>

                    <c:forEach var="member" items="${memberList}">
                        <tr class="memberRow" style="background-color: #ffffff;">
                            <td style="padding: 12px; border-bottom: 1px solid #ddd; text-align: center;">
                                <input type="checkbox" name="selectedMembers" value="${member.memberID}" style="transform: scale(1.5); cursor: pointer;">
                            </td>
                            <td style="padding: 12px; border-bottom: 1px solid #ddd;">${member.memberID}</td>
                            <td style="padding: 12px; border-bottom: 1px solid #ddd;">${member.name}</td>
                            <td style="padding: 12px; border-bottom: 1px solid #ddd;">${member.email}</td>
                            <td style="padding: 12px; border-bottom: 1px solid #ddd;">${member.program}</td>
                            <td style="padding: 12px; border-bottom: 1px solid #ddd; text-align: center; font-weight: bold;">${member.year}</td>
                        </tr>
                    </c:forEach>
                </table>
            </form>
        </div>

        <jsp:include page="footer.jsp" />
    </body>
</html>