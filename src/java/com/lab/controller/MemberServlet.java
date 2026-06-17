package com.lab.controller;

import com.lab.dao.UserDAO;
import com.lab.model.ClubMember;
import com.lab.model.ClubCommittee;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

// =========================================================================
// @MultipartConfig IS REQUIRED FOR CSV FILE UPLOADS
// This annotation tells Tomcat that this Servlet will accept multipart/form-data
// =========================================================================
@MultipartConfig 
@WebServlet(name = "MemberServlet", urlPatterns = {"/MemberServlet"})
public class MemberServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // Security: Ensure only the ADVISOR can access the Manage Members page
        if (!"ADVISOR".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        UserDAO dao = new UserDAO();
        
        // Fetch both lists independently to populate the two separate HTML tables
        request.setAttribute("memberList", dao.getAllStandardMembers());
        request.setAttribute("committeeList", dao.getAllCommitteeMembers());
        
        // Dispatch the data to the JSP view
        request.getRequestDispatcher("manageMembers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // Security Check: Block unauthorized POST requests
        if (!"ADVISOR".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        UserDAO dao = new UserDAO();

        /* ==========================================================
           ACTION 1: MANUALLY ADD A SINGLE USER
           ========================================================== */
        if ("add".equals(action)) {
            String role = request.getParameter("role");
            boolean isSuccess = false;

            if ("COMMITTEE".equals(role)) {
                ClubCommittee newCommittee = new ClubCommittee();
                newCommittee.setCommitteeID(request.getParameter("memberID")); 
                newCommittee.setName(request.getParameter("name"));
                newCommittee.setEmail(request.getParameter("email"));
                newCommittee.setPassword(request.getParameter("password"));
                newCommittee.setPhoneNo(request.getParameter("phoneNo"));
                newCommittee.setPosition(request.getParameter("position"));
                newCommittee.setProgram(request.getParameter("program"));
                newCommittee.setYear(Integer.parseInt(request.getParameter("year")));
                
                isSuccess = dao.registerCommittee(newCommittee);
            } else {
                ClubMember newMember = new ClubMember();
                newMember.setMemberID(request.getParameter("memberID")); 
                newMember.setName(request.getParameter("name"));
                newMember.setEmail(request.getParameter("email"));
                newMember.setPassword(request.getParameter("password"));
                newMember.setPhoneNo(request.getParameter("phoneNo"));
                newMember.setProgram(request.getParameter("program"));
                newMember.setYear(Integer.parseInt(request.getParameter("year")));
                
                isSuccess = dao.registerMember(newMember);
            }

            if (isSuccess) response.sendRedirect("MemberServlet?msg=added");
            else response.sendRedirect("MemberServlet?error=addFailed");
        } 
        
        /* ==========================================================
           ACTION 2: DELETE A USER
           ========================================================== */
        else if ("delete".equals(action)) {
            String memberId = request.getParameter("memberId"); 
            if (dao.deleteMember(memberId)) response.sendRedirect("MemberServlet?msg=deleted");
            else response.sendRedirect("MemberServlet?error=deleteFailed");
        } 
        
        /* ==========================================================
           ACTION 3: BULK CSV IMPORT
           ========================================================== */
        else if ("import".equals(action)) {
            // Retrieve the uploaded file part from the HTTP request
            Part filePart = request.getPart("file");
            
            try (InputStream fileContent = filePart.getInputStream(); 
                 BufferedReader reader = new BufferedReader(new InputStreamReader(fileContent))) {

                String line;
                boolean isFirstLine = true;
                
                // Read the CSV file line by line
                while ((line = reader.readLine()) != null) {
                    
                    // Skip the first row (CSV Headers)
                    if (isFirstLine) { 
                        isFirstLine = false; 
                        continue; 
                    }
                    
                    // Split the comma-separated values into an array
                    String[] data = line.split(",");
                    
                    // Validate that the row contains all 7 required columns
                    if (data.length >= 7) { 
                        String name = data[0].trim();
                        String email = data[1].trim();
                        String phone = data[2].trim();
                        String userRole = data[3].trim().toUpperCase();
                        String progOrPos = data[4].trim(); 
                        int year = Integer.parseInt(data[5].trim());
                        String studentId = data[6].trim();

                        // Route the data to the correct database table based on Role
                        if ("COMMITTEE".equals(userRole)) {
                            ClubCommittee newAJK = new ClubCommittee();
                            newAJK.setCommitteeID(studentId);
                            newAJK.setName(name);
                            newAJK.setEmail(email);
                            newAJK.setPassword("Comtech123!"); // Default Password
                            newAJK.setPhoneNo(phone);
                            newAJK.setPosition(progOrPos); // Map to Position
                            newAJK.setProgram("Computer Science"); // Default Program
                            newAJK.setYear(year);
                            
                            dao.registerCommittee(newAJK);
                        } else {
                            ClubMember newMem = new ClubMember();
                            newMem.setMemberID(studentId);
                            newMem.setName(name);
                            newMem.setEmail(email);
                            newMem.setPassword("Comtech123!"); // Default Password
                            newMem.setPhoneNo(phone);
                            newMem.setProgram(progOrPos); // Map to Program
                            newMem.setYear(year);
                            
                            dao.registerMember(newMem);
                        }
                    }
                }
                // Redirect with success message once the loop completes
                response.sendRedirect("MemberServlet?msg=added");
                
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("MemberServlet?error=importFailed");
            }
        }
    }
}