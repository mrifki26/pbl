package com.chilitrack.control.service;

import com.chilitrack.control.dto.ControlResponse;
import org.springframework.stereotype.Service;

import java.util.concurrent.atomic.AtomicBoolean;

@Service
public class ControlService {

    private final AtomicBoolean pumpStatus = new AtomicBoolean(false);

    public ControlResponse turnOn() {
        pumpStatus.set(true);
        return new ControlResponse("Pump ON", true);
    }

    public ControlResponse turnOff() {
        pumpStatus.set(false);
        return new ControlResponse("Pump OFF", false);
    }

    public ControlResponse getStatus() {
        boolean status = pumpStatus.get();
        return new ControlResponse(
                status ? "Pump ON" : "Pump OFF",
                status
        );
    }
}
