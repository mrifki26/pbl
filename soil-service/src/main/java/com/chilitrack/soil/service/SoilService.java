package com.chilitrack.soil.service;

import com.chilitrack.soil.dto.*;
import com.chilitrack.soil.entity.SoilData;
import com.chilitrack.soil.mapper.SoilMapper;
import com.chilitrack.soil.repository.SoilRepository;
import org.springframework.stereotype.Service;

@Service
public class SoilService {

    private final SoilRepository repo;

    public SoilService(SoilRepository repo) {
        this.repo = repo;
    }

    public void save(SoilRequest req) {
        repo.save(SoilMapper.toEntity(req));
    }

    public SoilResponse getLatest() {
        SoilData s = repo.findTopByOrderByIdDesc();
        if (s == null) return null;
        return SoilMapper.toResponse(s);
    }
}