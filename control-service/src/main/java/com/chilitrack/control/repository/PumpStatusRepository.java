package com.chilitrack.control.repository;

import com.chilitrack.control.entity.PumpStatus;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PumpStatusRepository extends JpaRepository<PumpStatus, String> {
}
