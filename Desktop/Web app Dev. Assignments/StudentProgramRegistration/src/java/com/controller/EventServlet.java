package com.controller;

import com.dao.EventDAO;
import com.model.Event;
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
            List<Event> events = "ADVISOR".equals(role) ? dao.getAdvisorEventReservations() : dao.getCommitteeEventReservations(userID);
            request.setAttribute("eventList", events);
            request.getRequestDispatcher("reservations.jsp").forward(request, response);
        } else if ("committeeHistory".equals(action) && "COMMITTEE".equals(role)) {
            String committeeID = (String) session.getAttribute("userId");
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

        /* CREATE EVENT (COMMITTEE) */
        if ("create".equals(action) && "COMMITTEE".equals(role)) {
            try {
                Event e = new Event();
                e.setEventName(request.getParameter("eventName"));

                String dateStr = request.getParameter("eventDate");
                String startStr = request.getParameter("startTime");
                String endStr = request.getParameter("endTime");

                if (dateStr == null || dateStr.isEmpty() || startStr == null || endStr == null) {
                    response.sendRedirect("createEvent.jsp?error=missing_fields");
                    return;
                }

                e.setEventDate(Date.valueOf(dateStr));
                e.setStartTime(Time.valueOf(startStr + ":00"));
                e.setEndTime(Time.valueOf(endStr + ":00"));
                e.setVenue(request.getParameter("venue"));

                String cap = request.getParameter("capacity");
                e.setCapacity(cap != null ? Integer.parseInt(cap) : 0);

                e.setDescription(request.getParameter("description"));
                e.setEventAJKs(request.getParameter("eventAJKs"));

                if (dao.addEvent(e, (String) session.getAttribute("userId"))) {
                    response.sendRedirect("EventServlet?action=listPending");
                } else {
                    response.sendRedirect("createEvent.jsp?error=db_failed");
                }
            } catch (IllegalArgumentException ex) {
                response.sendRedirect("createEvent.jsp?error=invalid_format");
            }
        }  else if ("updateStatus".equals(action) && "ADVISOR".equals(role)) {
            int id = Integer.parseInt(request.getParameter("eventID"));
            String status = request.getParameter("status");
            String comment = request.getParameter("comment"); // Pastikan comment ditangkap

            dao.updateEventStatus(id, status, comment);
            response.sendRedirect("EventServlet?action=listPending&t=" + System.currentTimeMillis());
        }  else if ("rsvp".equals(action) && "MEMBER".equals(role)) {
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
        }  else if ("cancelRsvp".equals(action) && "MEMBER".equals(role)) {
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

    private boolean isOverlapping(String memberID, int newEventID, EventDAO dao) {
        List<Event> myEvents = dao.getMyReservations(memberID);
        Event newEvent = getEventDetailsFromDAO(newEventID, dao);

        if (newEvent == null || myEvents == null || myEvents.isEmpty()) {
            return false;
        }

        for (Event e : myEvents) {
            if (e.getEventDate() != null && e.getEventDate().equals(newEvent.getEventDate())) {
                if (newEvent.getStartTime().before(e.getEndTime()) && newEvent.getEndTime().after(e.getStartTime())) {
                    return true;
                }
            }
        }
        return false;
    }

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
