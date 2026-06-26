package com.chilitrack.temperature.repository;

import com.chilitrack.temperature.entity.TemperatureData;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TemperatureRepository extends JpaRepository<TemperatureData, Long> {

    TemperatureData findTopByOrderByIdDesc();
}