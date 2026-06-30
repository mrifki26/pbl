package com.chilitrack.control.repository;

import com.chilitrack.control.entity.PumpControlHistory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PumpControlHistoryRepository extends JpaRepository<PumpControlHistory, Long> {

    List<PumpControlHistory> findTop20ByDeviceCodeOrderByControlledAtDesc(String deviceCode);
}
