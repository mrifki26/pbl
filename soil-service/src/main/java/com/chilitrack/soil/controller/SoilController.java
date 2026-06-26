package com.chilitrack.soil.controller;

import com.chilitrack.soil.dto.*;
import com.chilitrack.soil.service.SoilService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/soil")
public class SoilController {

    private final SoilService service;

    public SoilController(SoilService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<?> save(@Valid @RequestBody SoilRequest req) {
        service.save(req);
        return ResponseEntity.ok(Map.of("message", "Soil data saved"));
    }

    @GetMapping("/latest")
    public ResponseEntity<?> latest() {
        return ResponseEntity.ok(service.getLatest());
    }
}
