package com.lab.controller;

import com.lab.dao.UserDAO;
import com.lab.model.ClubMember;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "SignupServlet", urlPatterns = {"/SignupServlet"})
public class SignupServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        ClubMember newMember = new ClubMember();
        
        // ADD THIS LINE: Capture the ID from your signup.jsp form
        newMember.setMemberID(request.getParameter("memberID")); 
        
        newMember.setName(request.getParameter("name"));
        newMember.setEmail(request.getParameter("email"));
        newMember.setPassword(request.getParameter("password"));
        newMember.setPhoneNo(request.getParameter("phoneNo"));
        newMember.setProgram(request.getParameter("program"));
        newMember.setYear(Integer.parseInt(request.getParameter("year")));

        UserDAO dao = new UserDAO();
        if (dao.registerMember(newMember)) {
            response.sendRedirect("login.jsp?msg=registered");
        } else {
            response.sendRedirect("signup.jsp?error=true");
        }
    }
}