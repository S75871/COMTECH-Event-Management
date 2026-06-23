package com.controller;

import com.dao.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        UserDAO dao = new UserDAO();
        String[] authData = dao.authenticateUser(email, password);

        if (authData != null) {
            HttpSession session = request.getSession();
            session.setAttribute("userRole", authData[0]);
            session.setAttribute("userId", authData[1]); 
            session.setAttribute("userName", authData[2]);

            // Route based on role
            if (authData[0].equals("COMMITTEE")) {
                response.sendRedirect("home.jsp"); // Changed to redirect everyone to the dashboard first
            } else if (authData[0].equals("ADVISOR")) {
                response.sendRedirect("home.jsp");
            } else {
                response.sendRedirect("home.jsp");
            }
        } else {
            response.sendRedirect("login.jsp?error=invalid");
        }
    }
}
