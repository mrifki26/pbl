package com.chilitrack.control.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "pump_status")
public class PumpStatus {

    @Id
    private String deviceCode;

    @Column(nullable = false)
    private boolean pumpOn;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    protected PumpStatus() {
    }

    public PumpStatus(String deviceCode, boolean pumpOn) {
        this.deviceCode = deviceCode;
        this.pumpOn = pumpOn;
    }

    @PrePersist
    @PreUpdate
    void onSave() {
        updatedAt = LocalDateTime.now();
    }

    public String getDeviceCode() {
        return deviceCode;
    }

    public boolean isPumpOn() {
        return pumpOn;
    }

    public void setPumpOn(boolean pumpOn) {
        this.pumpOn = pumpOn;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
}
