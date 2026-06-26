package com.chilitrack.temperature.dto;

import jakarta.validation.constraints.NotNull;

public class TemperatureRequest {

    @NotNull
    public Double temperature;

    @NotNull
    public Long deviceId;
}