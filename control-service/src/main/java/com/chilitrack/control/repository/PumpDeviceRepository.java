package com.chilitrack.control.repository;

import com.chilitrack.control.entity.PumpDevice;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PumpDeviceRepository extends JpaRepository<PumpDevice, Long> {

    Optional<PumpDevice> findByDeviceCode(String deviceCode);
}
