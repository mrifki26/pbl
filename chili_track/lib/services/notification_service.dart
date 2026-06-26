import 'dart:async';
import 'package:flutter/material.dart';
import 'api_service.dart';

enum ChiliNotificationType { warning, activity, system }

class ChiliNotification {
  ChiliNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final ChiliNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  bool read;
}

class NotificationService extends ChangeNotifier {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final List<ChiliNotification> _items = [];
  Timer? _timer;
  bool? _lastPumpStatus;
  bool _soilDryActive = false;
  bool _soilWetActive = false;
  bool _started = false;

  List<ChiliNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((item) => !item.read).length;

  void start() {
    if (_started) return;
    _started = true;
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _poll());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _started = false;
  }

  void addWateringStarted() {
    _add(
      type: ChiliNotificationType.activity,
      title: "Pompa aktif",
      body: "Pompa penyiraman dinyalakan dari halaman Monitoring.",
      key: "pump-manual-${DateTime.now().millisecondsSinceEpoch}",
    );
  }

  void markAllRead() {
    for (final item in _items) {
      item.read = true;
    }
    notifyListeners();
  }

  Future<void> _poll() async {
    await Future.wait([_pollSoil(), _pollPump()]);
  }

  Future<void> _pollSoil() async {
    try {
      final soilData = await ApiService.getLatestSoil();
      final soil = (soilData['soilMoisture'] as num).toDouble();

      if (soil < 40 && !_soilDryActive) {
        _soilDryActive = true;
        _soilWetActive = false;
        _add(
          type: ChiliNotificationType.warning,
          title: "Tanah mulai kering",
          body:
              "Kelembapan tanah ${soil.toStringAsFixed(0)}%. Segera siram tanaman cabai.",
          key: "soil-dry",
        );
      } else if (soil > 80 && !_soilWetActive) {
        _soilWetActive = true;
        _soilDryActive = false;
        _add(
          type: ChiliNotificationType.warning,
          title: "Tanah terlalu lembab",
          body:
              "Kelembapan tanah ${soil.toStringAsFixed(0)}%. Kurangi penyiraman agar akar tetap sehat.",
          key: "soil-wet",
        );
      } else if (soil >= 40 && soil <= 80) {
        if (_soilDryActive) {
          _add(
            type: ChiliNotificationType.activity,
            title: "Cabai sudah disiram",
            body:
                "Kelembapan tanah kembali normal di ${soil.toStringAsFixed(0)}%.",
            key: "soil-normal-${DateTime.now().millisecondsSinceEpoch}",
          );
        }
        _soilDryActive = false;
        _soilWetActive = false;
      }
    } catch (_) {
      _add(
        type: ChiliNotificationType.system,
        title: "Sensor tanah belum terbaca",
        body: "Pastikan soil-service dan ESP32 aktif pada jaringan yang sama.",
        key: "soil-error",
        once: true,
      );
    }
  }

  Future<void> _pollPump() async {
    try {
      final statusData = await ApiService.getStatus();
      final pumpOn = statusData['status'] == true;

      if (_lastPumpStatus != null && _lastPumpStatus != pumpOn) {
        _add(
          type: ChiliNotificationType.activity,
          title: pumpOn ? "Pompa aktif" : "Pompa mati",
          body: pumpOn
              ? "Sistem mendeteksi pompa sedang menyiram tanaman."
              : "Penyiraman selesai, pompa sudah berhenti.",
          key: "pump-${DateTime.now().millisecondsSinceEpoch}",
        );
      }
      _lastPumpStatus = pumpOn;
    } catch (_) {
      _add(
        type: ChiliNotificationType.system,
        title: "Status pompa belum terbaca",
        body: "Pastikan control-service berjalan dan token login masih aktif.",
        key: "pump-error",
        once: true,
      );
    }
  }

  void _add({
    required ChiliNotificationType type,
    required String title,
    required String body,
    required String key,
    bool once = false,
  }) {
    if (once && _items.any((item) => item.id == key)) return;

    _items.insert(
      0,
      ChiliNotification(
        id: key,
        type: type,
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
    );

    if (_items.length > 30) {
      _items.removeRange(30, _items.length);
    }

    notifyListeners();
  }
}
