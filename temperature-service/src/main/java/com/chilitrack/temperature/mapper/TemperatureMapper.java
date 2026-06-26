package com.chilitrack.temperature.mapper;

import com.chilitrack.temperature.dto.*;
import com.chilitrack.temperature.entity.TemperatureData;

public class TemperatureMapper {

    public static TemperatureData toEntity(TemperatureRequest req) {
        TemperatureData t = new TemperatureData();
        t.setTemperature(req.temperature);
        t.setDeviceId(req.deviceId);
        return t;
    }

    public static TemperatureResponse toResponse(TemperatureData t) {
        TemperatureResponse r = new TemperatureResponse();
        r.temperature = t.getTemperature();
        r.deviceId = t.getDeviceId();
        r.createdAt = t.getCreatedAt();
        return r;
    }
}