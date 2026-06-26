package com.chilitrack.temperature.dto;

import java.time.LocalDateTime;

public class TemperatureResponse {

    public double temperature;
    public Long deviceId;
    public LocalDateTime createdAt;
}