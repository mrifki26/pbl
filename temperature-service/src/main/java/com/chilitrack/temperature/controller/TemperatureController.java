package com.chilitrack.temperature.controller;

import com.chilitrack.temperature.dto.*;
import com.chilitrack.temperature.service.TemperatureService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/temperature")
public class TemperatureController {

    private final TemperatureService service;

    public TemperatureController(TemperatureService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<?> save(@Valid @RequestBody TemperatureRequest req) {
        service.save(req);
        return ResponseEntity.ok(Map.of("message", "Temperature saved"));
    }

    @GetMapping("/latest")
    public ResponseEntity<?> latest() {
        return ResponseEntity.ok(service.getLatest());
    }
}
