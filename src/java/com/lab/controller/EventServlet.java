package com.lab.controller;

import com.lab.dao.EventDAO;
import com.lab.model.Event;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "EventServlet", urlPatterns = {"/EventServlet"})
public class EventServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");

        if (role == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        EventDAO dao = new EventDAO();

        /* ==========================================================
           GET ROUTING: Loading Pages & Data
           ========================================================== */
        if ("listPending".equals(action) && "ADVISOR".equals(role)) {
            request.setAttribute("pendingEvents", dao.getPendingEvents());
            request.getRequestDispatcher("pendingApproval.jsp").forward(request, response);
        } else if ("browse".equals(action) && "MEMBER".equals(role)) {
            request.setAttribute("availableEvents", dao.getAvailableEvents());
            request.getRequestDispatcher("browseEvents.jsp").forward(request, response);
        } else if ("myReservations".equals(action) && "MEMBER".equals(role)) {
            String memberID = (String) session.getAttribute("userId");
            request.setAttribute("myEvents", dao.getMyReservations(memberID));
            request.getRequestDispatcher("myReservations.jsp").forward(request, response);
        } else if ("advisorReservations".equals(action) || "committeeReservations".equals(action)) {
            String userID = (String) session.getAttribute("userId");
            List<Event> events;
            if ("ADVISOR".equals(role)) {
                events = dao.getAdvisorEventReservations();
            } else {
                events = dao.getCommitteeEventReservations(userID);
            }
            request.setAttribute("eventList", events);
            request.getRequestDispatcher("reservations.jsp").forward(request, response);
        } else if ("committeeHistory".equals(action) && "COMMITTEE".equals(role)) {
            String committeeID = (String) session.getAttribute("userId");
            // Assuming you added getCommitteeEventHistory to EventDAO
            request.setAttribute("eventHistory", dao.getCommitteeEventReservations(committeeID));
            request.getRequestDispatcher("eventHistory.jsp").forward(request, response);
        } else {
            response.sendRedirect("home.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");
        EventDAO dao = new EventDAO();

        if (role == null) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        if ("create".equals(action) && "COMMITTEE".equals(role)) {
            Event e = new Event();
            e.setEventName(request.getParameter("eventName"));
            e.setEventDate(Date.valueOf(request.getParameter("eventDate")));
            e.setStartTime(Time.valueOf(request.getParameter("startTime") + ":00"));
            e.setEndTime(Time.valueOf(request.getParameter("endTime") + ":00"));
            e.setVenue(request.getParameter("venue"));
            e.setCapacity(Integer.parseInt(request.getParameter("capacity")));
            e.setDescription(request.getParameter("description"));
            e.setEventAJKs(request.getParameter("eventAJKs"));

            if (dao.addEvent(e, (String) session.getAttribute("userId"))) {
                response.sendRedirect("EventServlet?action=listPending");
            } else {
                response.sendRedirect("createEvent.jsp?error=true");
            }
        } else if ("updateStatus".equals(action) && "ADVISOR".equals(role)) {
            int id = Integer.parseInt(request.getParameter("eventID"));
            dao.updateEventStatus(id, request.getParameter("status"), request.getParameter("comment"));
            response.sendRedirect("EventServlet?action=listPending");
        } else if ("rsvp".equals(action) && "MEMBER".equals(role)) {
            int eventID = Integer.parseInt(request.getParameter("eventID"));
            String memberID = (String) session.getAttribute("userId");

            if (isOverlapping(memberID, eventID, dao)) {
                session.setAttribute("showPopup", "true");
                session.setAttribute("popupText", "Event overlap detected with an existing reservation!");
                response.sendRedirect("EventServlet?action=browse");
            } else if (dao.registerForEvent(eventID, memberID)) {
                response.sendRedirect("EventServlet?action=browse&msg=rsvp_success");
            } else {
                response.sendRedirect("EventServlet?action=browse&error=failed");
            }
        } else if ("cancelRsvp".equals(action) && "MEMBER".equals(role)) {
            int eventID = Integer.parseInt(request.getParameter("eventID"));
            String memberID = (String) session.getAttribute("userId");

            if (dao.cancelReservation(eventID, memberID)) {
                response.sendRedirect("EventServlet?action=myReservations&msg=cancel_success");
            } else {
                response.sendRedirect("EventServlet?action=myReservations&error=cancel_failed");
            }
        } else {
            response.sendRedirect("login.jsp?error=unauthorized");
        }
    }

    /**
     * Logic to check if the new event overlaps with any confirmed reservations.
     * Uses the formula: (NewStart < ExistingEnd) AND (NewEnd > ExistingStart)
     */
    private boolean isOverlapping(String memberID, int newEventID, EventDAO dao) {
        // 1. Fetch current user's reservations
        List<Event> myEvents = dao.getMyReservations(memberID);
        
        // 2. Fetch details of the event the user is attempting to register for
        Event newEvent = getEventDetailsFromDAO(newEventID, dao); 

        // 3. Safety: If event doesn't exist or user has no previous bookings, no overlap
        if (newEvent == null || myEvents == null || myEvents.isEmpty()) {
            return false;
        }

        // 4. Compare times
        for (Event e : myEvents) {
            // Check if dates are the same (null-safe)
            if (e.getEventDate() != null && e.getEventDate().equals(newEvent.getEventDate())) {

                // Standard interval overlap formula:
                // An overlap occurs if the new event starts before the existing one ends,
                // AND the new event ends after the existing one starts.
                if (newEvent.getStartTime().before(e.getEndTime()) && 
                    newEvent.getEndTime().after(e.getStartTime())) {
                    return true; // Overlap detected
                }
            }
        }
        return false;
    }

    // Helper to fetch details of the event being booked
    private Event getEventDetailsFromDAO(int eventID, EventDAO dao) {
        List<Event> allEvents = dao.getAvailableEvents();
        for (Event e : allEvents) {
            if (e.getEventID() == eventID) {
                return e;
            }
        }
        return null;
    }
}
