package com.controller;

import com.dao.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ManageMembersServlet")
public class ManageMembersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();

        // Security: Ensure ONLY the Committee can access this page
        if (!"COMMITTEE".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        UserDAO dao = new UserDAO();
        String action = request.getParameter("action");

        // Single delete action
        if ("delete".equals(action)) {
            String memberIdToDelete = request.getParameter("id");
            dao.deleteMember(memberIdToDelete);
            response.sendRedirect("ManageMembersServlet?msg=deleted");
            return;
        }

        // Fetch data and forward to View
        request.setAttribute("memberList", dao.getAllStandardMembers());
        request.getRequestDispatcher("committeeManageMembers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        if (!"COMMITTEE".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String[] selectedMembers = request.getParameterValues("selectedMembers");

        if (selectedMembers == null || selectedMembers.length == 0) {
            response.sendRedirect("ManageMembersServlet?error=noneSelected");
            return;
        }

        UserDAO userDAO = new UserDAO();

        // Perform Bulk Delete
        if ("bulkDelete".equals(action)) {
            for (String memberId : selectedMembers) {
                userDAO.deleteMember(memberId);
            }
            response.sendRedirect("ManageMembersServlet?msg=bulkDeleted");
        } else {
            response.sendRedirect("ManageMembersServlet?error=invalidAction");
        }
    }
}