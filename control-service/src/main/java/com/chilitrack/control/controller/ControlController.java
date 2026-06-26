package com.chilitrack.control.controller;

import com.chilitrack.control.dto.ControlResponse;
import com.chilitrack.control.service.ControlService;
import org.springframework.web.bind.annotation.*;

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
}
