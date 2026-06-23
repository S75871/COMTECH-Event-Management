package com.controller;

import com.dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;


@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {


    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ProfileServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ProfileServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    // GET request loads the data and sends it to profile.jsp
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String userRole = (String) session.getAttribute("userRole");

        if (userId != null && userRole != null) {
            UserDAO dao = new UserDAO();
            String[] profileData = dao.getUserProfileData(userId, userRole);

            request.setAttribute("profileData", profileData);
            request.getRequestDispatcher("profile.jsp").forward(request, response);
        } else {
            response.sendRedirect("login.jsp");
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    // POST request handles the form submission
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String userRole = (String) session.getAttribute("userRole");

        if (userId != null) {
            String currentPasswordInput = request.getParameter("currentPassword");
            String newPhone = request.getParameter("phoneNo");
            String newPassword = request.getParameter("newPassword");

            UserDAO dao = new UserDAO();
            String[] currentData = dao.getUserProfileData(userId, userRole);

            // SECURITY CHECK: Verify the current password matches the database
            if (!currentData[4].equals(currentPasswordInput)) {
                response.sendRedirect("ProfileServlet?error=wrongPassword");
                return;
            }

            // SMART LOGIC: If they leave the New Password blank, keep the old password
            if (newPassword == null || newPassword.trim().isEmpty()) {
                newPassword = currentData[4]; // Use existing
            }

            if (dao.updateProfile(userId, userRole, newPhone, newPassword)) {
                response.sendRedirect("ProfileServlet?msg=success");
            } else {
                response.sendRedirect("ProfileServlet?error=failed");
            }
        } else {
            response.sendRedirect("login.jsp");
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
