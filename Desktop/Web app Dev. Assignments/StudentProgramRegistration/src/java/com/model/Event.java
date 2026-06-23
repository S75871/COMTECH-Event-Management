package com.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Time;

public class Event implements Serializable {

    private int eventID;
    private String eventName;
    private Date eventDate;
    private Time startTime;
    private Time endTime;
    private String venue;
    private int capacity;
    private String description;
    private String eventAJKs;
    private String status;
    private String advisorComment;
    private int registeredCount;
    private String participantNames;

    public Event() {
    }

    public int getEventID() {
        return eventID;
    }

    public void setEventID(int eventID) {
        this.eventID = eventID;
    }

    public String getEventName() {
        return eventName;
    }

    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    public Date getEventDate() {
        return eventDate;
    }

    public void setEventDate(Date eventDate) {
        this.eventDate = eventDate;
    }

    public Time getStartTime() {
        return startTime;
    }

    public void setStartTime(Time startTime) {
        this.startTime = startTime;
    }

    public Time getEndTime() {
        return endTime;
    }

    public void setEndTime(Time endTime) {
        this.endTime = endTime;
    }

    public String getVenue() {
        return venue;
    }

    public void setVenue(String venue) {
        this.venue = venue;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getEventAJKs() {
        return eventAJKs;
    }

    public void setEventAJKs(String eventAJKs) {
        this.eventAJKs = eventAJKs;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getAdvisorComment() {
        return advisorComment;
    }

    public void setAdvisorComment(String advisorComment) {
        this.advisorComment = advisorComment;
    }

    public int getRegisteredCount() {
        return registeredCount;
    }

    public void setRegisteredCount(int registeredCount) {
        this.registeredCount = registeredCount;
    }

    public String getParticipantNames() {
        return participantNames;
    }

    public void setParticipantNames(String participantNames) {
        this.participantNames = participantNames;
    }
}
