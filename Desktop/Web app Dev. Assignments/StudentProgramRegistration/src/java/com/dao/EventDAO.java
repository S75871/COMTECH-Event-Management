package com.dao;

import com.dao.DBConnection;
import com.model.Event;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object (DAO) for managing Event persistence.
 * This class handles all CRUD and analytical queries related to club events.
 */
public class EventDAO {

    /* =========================================================================
       SECTION 1: CORE EVENT MANAGEMENT (CREATE & UPDATE)
       ========================================================================= */
       
    /**
     * Inserts a new event proposal into the database.
     */
    public boolean addEvent(Event event, String committeeId) {
        String sql = "INSERT INTO club_event (committeeID, eventName, eventDate, startTime, endTime, venue, capacity, description, eventAJKs, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending Approval')";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, committeeId);
            ps.setString(2, event.getEventName());
            ps.setDate(3, event.getEventDate());
            ps.setTime(4, event.getStartTime());
            ps.setTime(5, event.getEndTime());
            ps.setString(6, event.getVenue());
            ps.setInt(7, event.getCapacity());
            ps.setString(8, event.getDescription());
            ps.setString(9, event.getEventAJKs());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("DAO ERROR (addEvent): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Updates the status and advisor feedback for an existing event.
     */
    public boolean updateEventStatus(int eventID, String status, String comment) {
        String sql = "UPDATE club_event SET status = ?, advisorComment = ? WHERE eventID = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, comment);
            ps.setInt(3, eventID);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("DAO ERROR (updateEventStatus): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /* =========================================================================
       SECTION 2: DASHBOARD & HISTORY QUERIES
       ========================================================================= */
       
    /**
     * Fetches all events currently awaiting advisor approval.
     */
    public List<Event> getPendingEvents() {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT * FROM club_event WHERE status = 'Pending Approval' ORDER BY eventDate ASC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Event e = new Event();
                e.setEventID(rs.getInt("eventID"));
                e.setEventName(rs.getString("eventName"));
                e.setEventDate(rs.getDate("eventDate"));
                e.setStartTime(rs.getTime("startTime"));
                e.setEndTime(rs.getTime("endTime"));
                e.setVenue(rs.getString("venue"));
                e.setCapacity(rs.getInt("capacity"));
                e.setStatus(rs.getString("status"));
                e.setDescription(rs.getString("description"));
                String comment = rs.getString("advisorComment");
                e.setAdvisorComment(comment != null ? comment : "No comments yet.");
                events.add(e);
            }
        } catch (Exception e) {
            System.out.println("DAO ERROR (getPendingEvents): " + e.getMessage());
        }
        return events;
    }

    /**
     * Fetches a limited list of pending events for summary dashboards.
     */
    public List<Event> getRecentPendingEvents(int limit) {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT * FROM club_event WHERE status = 'Pending Approval' ORDER BY eventDate ASC LIMIT ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Event e = new Event();
                    e.setEventName(rs.getString("eventName"));
                    e.setEventDate(rs.getDate("eventDate"));
                    e.setStatus(rs.getString("status"));
                    e.setDescription(rs.getString("description"));
                    events.add(e);
                }
            }
        } catch (Exception e) {
            System.out.println("DAO ERROR (getRecentPendingEvents): " + e.getMessage());
        }
        return events;
    }

    /**
     * Fetches a history of recently processed (Approved/Rejected) events.
     */
    public List<Event> getRecentEventHistory(int limit) {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT * FROM club_event WHERE status != 'Pending Approval' ORDER BY eventDate DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Event e = new Event();
                    e.setEventName(rs.getString("eventName"));
                    e.setEventDate(rs.getDate("eventDate"));
                    e.setStatus(rs.getString("status"));
                    String comment = rs.getString("advisorComment");
                    e.setAdvisorComment(comment != null ? comment : "No feedback provided.");
                    events.add(e);
                }
            }
        } catch (Exception e) {
            System.out.println("DAO ERROR (getRecentEventHistory): " + e.getMessage());
        }
        return events;
    }

    /* =========================================================================
       SECTION 3: ROSTERS, CATALOG & REGISTRATIONS
       ========================================================================= */
       
    /**
     * Retrieves all approved events currently open for registration.
     */
    public List<Event> getAvailableEvents() {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT e.*, (SELECT COUNT(*) FROM event_registration WHERE eventID = e.eventID AND status = 'Confirmed') AS currentRSVPs " +
                     "FROM club_event e WHERE e.status = 'Approved' ORDER BY e.eventDate ASC";
                     
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Event e = new Event();
                e.setEventID(rs.getInt("eventID"));
                e.setEventName(rs.getString("eventName"));
                e.setEventDate(rs.getDate("eventDate"));
                e.setStartTime(rs.getTime("startTime"));
                e.setEndTime(rs.getTime("endTime"));
                e.setVenue(rs.getString("venue"));
                e.setCapacity(rs.getInt("capacity"));
                e.setDescription(rs.getString("description"));
                e.setEventAJKs(rs.getString("eventAJKs")); 
                e.setRegisteredCount(rs.getInt("currentRSVPs")); 
                events.add(e);
            }
        } catch (Exception e) {
            System.out.println("DAO ERROR (getAvailableEvents): " + e.getMessage());
        }
        return events;
    }

    /**
     * Records a new user registration for a specific event.
     */
    public boolean registerForEvent(int eventID, String memberID) {
        String sql = "INSERT INTO event_registration (eventID, memberID, status) VALUES (?, ?, 'Confirmed')";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventID);
            ps.setString(2, memberID);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("DAO ERROR (registerForEvent): " + e.getMessage());
            return false;
        }
    }

    /**
     * Deletes a user's registration for a specific event.
     */
    public boolean cancelReservation(int eventID, String memberID) {
        String sql = "DELETE FROM event_registration WHERE eventID = ? AND memberID = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventID);
            ps.setString(2, memberID);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("DAO ERROR (cancelReservation): " + e.getMessage());
            return false;
        }
    }

    /**
     * Fetches all events registered to a specific member ID.
     */
    public List<Event> getMyReservations(String memberID) {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT e.*, r.status AS rsvpStatus FROM club_event e " +
                     "JOIN event_registration r ON e.eventID = r.eventID " +
                     "WHERE r.memberID = ? ORDER BY e.eventDate ASC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, memberID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Event e = new Event();
                    e.setEventID(rs.getInt("eventID"));
                    e.setEventName(rs.getString("eventName"));
                    e.setEventDate(rs.getDate("eventDate"));
                    e.setStartTime(rs.getTime("startTime"));
                    e.setEndTime(rs.getTime("endTime"));
                    e.setVenue(rs.getString("venue"));
                    e.setCapacity(rs.getInt("capacity"));
                    e.setDescription(rs.getString("description"));
                    e.setEventAJKs(rs.getString("eventAJKs"));
                    e.setStatus(rs.getString("rsvpStatus")); 
                    events.add(e);
                }
            }
        } catch (Exception e) {
            System.out.println("DAO ERROR (getMyReservations): " + e.getMessage());
        }
        return events;
    }

    /* =========================================================================
       SECTION 4: RESERVATION VIEWING (ADVISOR/COMMITTEE)
       ========================================================================= */

    /**
     * Fetches approved events with concatenated participant details for advisor review.
     */
    public List<Event> getAdvisorEventReservations() {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT e.*, (SELECT COUNT(*) FROM event_registration WHERE eventID = e.eventID AND status = 'Confirmed') AS currentRSVPs, " +
                     "(SELECT GROUP_CONCAT(CONCAT(er.memberID, '||', COALESCE(m.name, c.name, 'Unknown'), '||', COALESCE(m.program, c.program, 'N/A'), '||', COALESCE(m.email, c.email, 'N/A'), '||', COALESCE(m.year, c.year, '-')) SEPARATOR '###') " +
                     "FROM event_registration er LEFT JOIN ClubMember m ON er.memberID = m.memberID LEFT JOIN ClubCommittee c ON er.memberID = c.committeeID " +
                     "WHERE er.eventID = e.eventID AND er.status = 'Confirmed') AS attendees " +
                     "FROM club_event e WHERE e.status = 'Approved' ORDER BY e.eventDate DESC";
                     
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                events.add(populateEventFromResultSet(rs));
            }
        } catch (Exception e) {
            System.out.println("DAO ERROR (getAdvisorEventReservations): " + e.getMessage());
        }
        return events;
    }
    
    /**
     * Fetches approved events with concatenated participant details for committee viewing.
     */
    public List<Event> getCommitteeEventReservations(String committeeID) {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT e.*, (SELECT COUNT(*) FROM event_registration WHERE eventID = e.eventID AND status = 'Confirmed') AS currentRSVPs, " +
                     "(SELECT GROUP_CONCAT(CONCAT(er.memberID, '||', COALESCE(m.name, c.name, 'Unknown'), '||', COALESCE(m.program, c.program, 'N/A'), '||', COALESCE(m.email, c.email, 'N/A'), '||', COALESCE(m.year, c.year, '-')) SEPARATOR '###') " +
                     "FROM event_registration er LEFT JOIN ClubMember m ON er.memberID = m.memberID LEFT JOIN ClubCommittee c ON er.memberID = c.committeeID " +
                     "WHERE er.eventID = e.eventID AND er.status = 'Confirmed') AS attendees " +
                     "FROM club_event e WHERE e.status = 'Approved' ORDER BY e.eventDate DESC";
                     
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                events.add(populateEventFromResultSet(rs));
            }
        } catch (Exception e) {
            System.out.println("DAO ERROR (getCommitteeEventReservations): " + e.getMessage());
        }
        return events;
    }

    /**
 * Fetches the event history (Approved/Rejected/Completed) specifically for one committee.
 */
public List<Event> getCommitteeEventHistory(String committeeID) {
    List<Event> events = new ArrayList<>();
    // Filter by committeeID and exclude 'Pending Approval'
    String sql = "SELECT * FROM club_event WHERE committeeID = ? AND status != 'Pending Approval' ORDER BY eventDate DESC";
    try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, committeeID);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Event e = new Event();
                e.setEventName(rs.getString("eventName"));
                e.setEventDate(rs.getDate("eventDate"));
                e.setStatus(rs.getString("status"));
                String comment = rs.getString("advisorComment");
                e.setAdvisorComment(comment != null ? comment : "No feedback provided.");
                events.add(e);
            }
        }
    } catch (Exception e) {
        System.out.println("DAO ERROR (getCommitteeEventHistory): " + e.getMessage());
    }
    return events;
}
    /**
     * Helper method to map a ResultSet row into an Event object.
     */
    private Event populateEventFromResultSet(ResultSet rs) throws Exception {
        Event e = new Event();
        e.setEventID(rs.getInt("eventID"));
        e.setEventName(rs.getString("eventName"));
        e.setEventDate(rs.getDate("eventDate"));
        e.setStartTime(rs.getTime("startTime"));
        e.setEndTime(rs.getTime("endTime"));
        e.setVenue(rs.getString("venue"));
        e.setCapacity(rs.getInt("capacity"));
        e.setDescription(rs.getString("description"));
        e.setEventAJKs(rs.getString("eventAJKs"));
        e.setStatus(rs.getString("status"));
        e.setRegisteredCount(rs.getInt("currentRSVPs"));
        String attendees = rs.getString("attendees");
        e.setParticipantNames(attendees != null ? attendees : "");
        return e;
    }
}