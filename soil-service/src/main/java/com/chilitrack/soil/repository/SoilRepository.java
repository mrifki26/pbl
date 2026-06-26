package com.chilitrack.soil.repository;

import com.chilitrack.soil.entity.SoilData;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SoilRepository extends JpaRepository<SoilData, Long> {

    SoilData findTopByOrderByIdDesc();
}