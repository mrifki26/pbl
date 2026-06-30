package com.chilitrack.control.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "pump_control_history")
public class PumpControlHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 80)
    private String deviceCode;

    @Column(nullable = false, length = 20)
    private String action;

    @Column(nullable = false)
    private boolean pumpOn;

    @Column(nullable = false, length = 160)
    private String message;

    @Column(nullable = false, updatable = false)
    private LocalDateTime controlledAt;

    protected PumpControlHistory() {
    }

    public PumpControlHistory(String deviceCode, String action, boolean pumpOn, String message) {
        this.deviceCode = deviceCode;
        this.action = action;
        this.pumpOn = pumpOn;
        this.message = message;
    }

    @PrePersist
    void onCreate() {
        controlledAt = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public String getDeviceCode() {
        return deviceCode;
    }

    public String getAction() {
        return action;
    }

    public boolean isPumpOn() {
        return pumpOn;
    }

    public String getMessage() {
        return message;
    }

    public LocalDateTime getControlledAt() {
        return controlledAt;
    }
}
