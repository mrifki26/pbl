package com.chilitrack.soil.dto;

import jakarta.validation.constraints.NotNull;

public class SoilRequest {

    @NotNull
    public Double soilMoisture;

    @NotNull
    public Long deviceId;

    @NotNull
    public Integer soilRaw;
}