package com.chilitrack.gateway;

import java.time.Instant;
import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class RootController {

    @GetMapping("/")
    public Map<String, Object> root() {
        return Map.of(
                "application", "ChiliTrack API",
                "description", "IoT Monitoring and Automatic Watering System",
                "status", "UP",
                "version", "1.0.0",
                "gateway", "Running",
                "timestamp", Instant.now(),
                "services", List.of(
                        "Auth Service",
                        "Soil Service",
                        "Temperature Service",
                        "Control Service"
                )
        );
    }
}
