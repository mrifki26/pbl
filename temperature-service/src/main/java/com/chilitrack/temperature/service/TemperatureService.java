package com.chilitrack.temperature.service;

import com.chilitrack.temperature.dto.*;
import com.chilitrack.temperature.entity.TemperatureData;
import com.chilitrack.temperature.mapper.TemperatureMapper;
import com.chilitrack.temperature.repository.TemperatureRepository;
import org.springframework.stereotype.Service;

@Service
public class TemperatureService {

    private final TemperatureRepository repo;

    public TemperatureService(TemperatureRepository repo) {
        this.repo = repo;
    }

    public void save(TemperatureRequest req) {
        repo.save(TemperatureMapper.toEntity(req));
    }

    public TemperatureResponse getLatest() {
        TemperatureData t = repo.findTopByOrderByIdDesc();
        if (t == null) return null;
        return TemperatureMapper.toResponse(t);
    }
}