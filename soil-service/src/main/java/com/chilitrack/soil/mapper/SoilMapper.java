package com.chilitrack.soil.mapper;

import com.chilitrack.soil.dto.*;
import com.chilitrack.soil.entity.SoilData;

public class SoilMapper {

    public static SoilData toEntity(SoilRequest req) {
        SoilData s = new SoilData();
        s.setSoilMoisture(req.soilMoisture);
        s.setDeviceId(req.deviceId);
        s.setSoilRaw(req.soilRaw);
        return s;
    }

    public static SoilResponse toResponse(SoilData s) {
        SoilResponse r = new SoilResponse();
        r.soilMoisture = s.getSoilMoisture();
        r.deviceId = s.getDeviceId();
        r.soilRaw = s.getSoilRaw();
        r.createdAt = s.getCreatedAt();
        return r;
    }
}