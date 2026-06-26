package com.chilitrack.control.dto;

public class ControlResponse {

    public String message;
    public boolean status;

    public ControlResponse(String message, boolean status) {
        this.message = message;
        this.status = status;
    }
}