package com.controller;

import com.dao.UserDAO;
import com.model.ClubMember;
import com.model.ClubCommittee;
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

@MultipartConfig
@WebServlet(name = "MemberServlet", urlPatterns = {"/MemberServlet"})
public class MemberServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (!"ADVISOR".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }
        UserDAO dao = new UserDAO();
        request.setAttribute("memberList", dao.getAllStandardMembers());
        request.setAttribute("committeeList", dao.getAllCommitteeMembers());
        request.getRequestDispatcher("manageMembers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (!"ADVISOR".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        UserDAO dao = new UserDAO();

        // ACTION 1: MANUALLY ADD A USER
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

            if (isSuccess) {
                response.sendRedirect("MemberServlet?msg=added");
            } else {
                response.sendRedirect("MemberServlet?error=addFailed");
            }

        // ACTION 2: DELETE A USER
        } else if ("delete".equals(action)) {
            String memberId = request.getParameter("memberId");
            if (dao.deleteMember(memberId)) {
                response.sendRedirect("MemberServlet?msg=deleted");
            } else {
                response.sendRedirect("MemberServlet?error=deleteFailed");
            }

        // ACTION 3: BULK CSV IMPORT (UPDATED WITH LOGGING)
        } else if ("import".equals(action)) {
            Part filePart = request.getPart("file");
            StringBuilder errorLog = new StringBuilder();
            int successCount = 0;
            int row = 0;

            try (InputStream fileContent = filePart.getInputStream(); 
                 BufferedReader reader = new BufferedReader(new InputStreamReader(fileContent))) {
                
                String line;
                boolean isFirstLine = true;

                while ((line = reader.readLine()) != null) {
                    row++;
                    if (isFirstLine) { isFirstLine = false; continue; } // Skip header row
                    if (line.trim().isEmpty()) continue; // Skip empty rows
                    
                    // Smart Splitter: Can read comma (,) or semicolon (;)
                    String separator = line.contains(";") ? ";" : ",";
                    String[] data = line.split(separator);

                    if (data.length >= 7) {
                        try {
                            String name = data[0].replaceAll("\"", "").trim();
                            String email = data[1].replaceAll("\"", "").trim();
                            String phone = data[2].replaceAll("\"", "").trim();
                            String role = data[3].replaceAll("\"", "").trim().toUpperCase();
                            String programOrPos = data[4].replaceAll("\"", "").trim();
                            
                            // Force numeric extraction only
                            String yearStr = data[5].replaceAll("[^0-9]", ""); 
                            int year = yearStr.isEmpty() ? 1 : Integer.parseInt(yearStr);
                            
                            String studentId = data[6].replaceAll("\"", "").trim();
                            
                            boolean isSuccess = false;

                            if ("COMMITTEE".equals(role)) {
                                ClubCommittee newC = new ClubCommittee();
                                newC.setCommitteeID(studentId);
                                newC.setName(name);
                                newC.setEmail(email);
                                newC.setPassword("password123");
                                newC.setPhoneNo(phone);
                                newC.setPosition(programOrPos);
                                newC.setProgram("N/A");
                                newC.setYear(year);
                                isSuccess = dao.registerCommittee(newC);
                            } else {
                                ClubMember newM = new ClubMember();
                                newM.setMemberID(studentId);
                                newM.setName(name);
                                newM.setEmail(email);
                                newM.setPassword("password123");
                                newM.setPhoneNo(phone);
                                newM.setProgram(programOrPos);
                                newM.setYear(year);
                                isSuccess = dao.registerMember(newM);
                            }

                            if (isSuccess) {
                                successCount++;
                            } else {
                                errorLog.append("Row ").append(row).append(" (").append(name).append(") : Rejected by Database (ID/Email might already exist, or column size is too small).\n");
                            }

                        } catch (Exception e) {
                            errorLog.append("Row ").append(row).append(" : Error reading data format.\n");
                        }
                    } else {
                        errorLog.append("Row ").append(row).append(" : Insufficient data columns! (Only found ").append(data.length).append(" columns).\n");
                    }
                }

                // Send report to UI screen
                if (successCount > 0 && errorLog.length() == 0) {
                    response.sendRedirect("MemberServlet?msg=added");
                } else {
                    request.getSession().setAttribute("importError", "Successfully Saved: " + successCount + " members.\n\nError List:\n" + errorLog.toString());
                    response.sendRedirect("MemberServlet?error=importLog");
                }

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("MemberServlet?error=importFailed");
            }
        }
    }
}