package com.chilitrack.control.service;

import com.chilitrack.control.dto.ControlResponse;
import com.chilitrack.control.dto.PumpDeviceRequest;
import com.chilitrack.control.entity.PumpControlHistory;
import com.chilitrack.control.entity.PumpDevice;
import com.chilitrack.control.entity.PumpStatus;
import com.chilitrack.control.repository.PumpControlHistoryRepository;
import com.chilitrack.control.repository.PumpDeviceRepository;
import com.chilitrack.control.repository.PumpStatusRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ControlService {

    private static final String DEFAULT_DEVICE_CODE = "PUMP-001";

    private final PumpDeviceRepository deviceRepository;
    private final PumpStatusRepository statusRepository;
    private final PumpControlHistoryRepository historyRepository;

    public ControlService(
            PumpDeviceRepository deviceRepository,
            PumpStatusRepository statusRepository,
            PumpControlHistoryRepository historyRepository
    ) {
        this.deviceRepository = deviceRepository;
        this.statusRepository = statusRepository;
        this.historyRepository = historyRepository;
    }

    @Transactional
    public ControlResponse turnOn() {
        return setPumpStatus(true);
    }

    @Transactional
    public ControlResponse turnOff() {
        return setPumpStatus(false);
    }

    @Transactional
    public ControlResponse getStatus() {
        PumpStatus currentStatus = getCurrentStatus();
        boolean status = currentStatus.isPumpOn();
        return new ControlResponse(
                status ? "Pump ON" : "Pump OFF",
                status
        );
    }

    @Transactional(readOnly = true)
    public List<PumpControlHistory> getHistory() {
        return historyRepository.findTop20ByDeviceCodeOrderByControlledAtDesc(DEFAULT_DEVICE_CODE);
    }

    @Transactional(readOnly = true)
    public List<PumpDevice> getDevices() {
        return deviceRepository.findAll();
    }

    @Transactional
    public PumpDevice saveDevice(PumpDeviceRequest request) {
        String deviceCode = cleanOrDefault(request.deviceCode, DEFAULT_DEVICE_CODE);
        String name = cleanOrDefault(request.name, "Main Water Pump");
        String location = cleanOrDefault(request.location, "Chili Track Field");
        boolean active = request.active == null || request.active;

        PumpDevice device = deviceRepository.findByDeviceCode(deviceCode)
                .orElseGet(() -> new PumpDevice(deviceCode, name, location));
        device.setName(name);
        device.setLocation(location);
        device.setActive(active);

        return deviceRepository.save(device);
    }

    private ControlResponse setPumpStatus(boolean pumpOn) {
        ensureDefaultDevice();

        PumpStatus currentStatus = statusRepository.findById(DEFAULT_DEVICE_CODE)
                .orElseGet(() -> new PumpStatus(DEFAULT_DEVICE_CODE, false));
        currentStatus.setPumpOn(pumpOn);
        statusRepository.save(currentStatus);

        String message = pumpOn ? "Pump ON" : "Pump OFF";
        historyRepository.save(new PumpControlHistory(
                DEFAULT_DEVICE_CODE,
                pumpOn ? "ON" : "OFF",
                pumpOn,
                message
        ));

        return new ControlResponse(message, pumpOn);
    }

    private PumpStatus getCurrentStatus() {
        ensureDefaultDevice();
        return statusRepository.findById(DEFAULT_DEVICE_CODE)
                .orElseGet(() -> statusRepository.save(new PumpStatus(DEFAULT_DEVICE_CODE, false)));
    }

    private void ensureDefaultDevice() {
        deviceRepository.findByDeviceCode(DEFAULT_DEVICE_CODE)
                .orElseGet(() -> deviceRepository.save(new PumpDevice(
                        DEFAULT_DEVICE_CODE,
                        "Main Water Pump",
                        "Chili Track Field"
                )));
    }

    private String cleanOrDefault(String value, String fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        return value.trim();
    }
}
