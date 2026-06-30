package com.chilitrack.control.controller;

import com.chilitrack.control.dto.ControlResponse;
import com.chilitrack.control.dto.PumpDeviceRequest;
import com.chilitrack.control.entity.PumpControlHistory;
import com.chilitrack.control.entity.PumpDevice;
import com.chilitrack.control.service.ControlService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/control")
public class ControlController {

    private final ControlService service;

    public ControlController(ControlService service) {
        this.service = service;
    }

    @GetMapping
    public String test() {
        return "Control Service Running";
    }

    @PostMapping("/on")
    public ControlResponse on() {
        return service.turnOn();
    }

    @PostMapping("/off")
    public ControlResponse off() {
        return service.turnOff();
    }

    @GetMapping("/status")
    public ControlResponse status() {
        return service.getStatus();
    }

    @GetMapping("/history")
    public List<PumpControlHistory> history() {
        return service.getHistory();
    }

    @GetMapping("/devices")
    public List<PumpDevice> devices() {
        return service.getDevices();
    }

    @PostMapping("/devices")
    public PumpDevice saveDevice(@RequestBody PumpDeviceRequest request) {
        return service.saveDevice(request);
    }
}
