package com.chilitrack.soil.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "soil_data")
public class SoilData {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private double soilMoisture;
    private Long deviceId;
    private Integer soilRaw;
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }

    public double getSoilMoisture() { return soilMoisture; }
    public void setSoilMoisture(double soilMoisture) {
        this.soilMoisture = soilMoisture;
    }

    public Long getDeviceId() { return deviceId; }
    public void setDeviceId(Long deviceId) {
        this.deviceId = deviceId;
    }

    public Integer getSoilRaw() { return soilRaw; }
public void setSoilRaw(Integer soilRaw) { this.soilRaw = soilRaw; }
    

    public LocalDateTime getCreatedAt() { return createdAt; }
}