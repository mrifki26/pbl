import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/sensor_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/app_logo.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const int activeSensors = 2;

  SensorModel? sensor;
  SensorModel? lastSensor;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    loadData();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => loadData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final soilData = await ApiService.getLatestSoil();
      final tempData = await ApiService.getLatestTemperature();

      final newData = SensorModel(
        soil: (soilData['soilMoisture'] as num).toDouble(),
        temp: (tempData['temperature'] as num).toDouble(),
      );

      if (!mounted) return;
      setState(() {
        sensor = newData;
        lastSensor = newData;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => sensor = lastSensor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = sensor ?? lastSensor;
    final soil = data?.soil ?? 0.0;
    final temp = data?.temp ?? 0.0;
    final health = data == null
        ? 0
        : ((_soilMoistureScore(soil) + _temperatureScore(temp)) / 2).round();
    final humidity = soil.clamp(0, 100).round();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: AuthService.getUsername(),
              builder: (context, snapshot) {
                final username = snapshot.data ?? "Petani";

                return _TopBar(
                  title: "Halo, $username!",
                  subtitle: "ChiliTrack",
                );
              },
            ),
            const SizedBox(height: 18),
            _HealthCard(health: health),
            const SizedBox(height: 10),
            _ClimateCard(temp: temp, humidity: humidity),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _SoilCard(soil: soil)),
                const SizedBox(width: 12),
                Expanded(child: _ActiveDeviceCard(count: activeSensors)),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "",
                style: TextStyle(color: Color(0xFF777A82), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _temperatureScore(double temp) {
    if (temp <= 0) return 0;
    if (temp >= 24 && temp <= 28) return 100;

    final distance = temp < 24 ? 24 - temp : temp - 28;
    return (100 - distance * 8).clamp(0, 100).toDouble();
  }

  double _soilMoistureScore(double soil) {
    if (soil <= 0) return 0;
    if (soil >= 60 && soil <= 80) return 100;

    final distance = soil < 60 ? 60 - soil : soil - 80;
    return (100 - distance * 3).clamp(0, 100).toDouble();
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE8E8EA)),
          ),
          padding: const EdgeInsets.all(6),
          child: const AppLogo(size: 42),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF777A82), fontSize: 12),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        AnimatedBuilder(
          animation: NotificationService.instance,
          builder: (context, _) {
            return _NotificationBadge(
              count: NotificationService.instance.unreadCount,
            );
          },
        ),
      ],
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 9 ? "9+" : "$count",
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.health});

  final int health;

  @override
  Widget build(BuildContext context) {
    final status = health >= 80
        ? "Optimal"
        : health >= 55
        ? "Perlu Dipantau"
        : "Butuh Air";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.redGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            bottom: -34,
            child: Icon(
              Icons.eco_rounded,
              size: 108,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "INDEKS KESEHATAN TANAMAN",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$health%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Text(
                      status,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Tanaman cabai rawit sedang dipantau secara real-time.",
                style: TextStyle(color: Colors.white, height: 1.35),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClimateCard extends StatelessWidget {
  const _ClimateCard({required this.temp, required this.humidity});

  final double temp;
  final int humidity;

  @override
  Widget build(BuildContext context) {
    final temperatureStatus = _temperatureStatusFor(temp);

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("LINGKUNGAN", style: _sectionLabelStyle),
                    SizedBox(height: 4),
                    Text("Data Iklim", style: _sectionTitleStyle),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.thermostat_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MetricValue(
                  value: "${temp.toStringAsFixed(0)}C",
                  label: "Suhu Tanah",
                  status: temperatureStatus.message,
                  statusColor: temperatureStatus.color,
                ),
              ),
              Container(width: 1, height: 42, color: const Color(0xFFE5E6EA)),
              Expanded(
                child: _MetricValue(value: "$humidity%", label: "Kelembapan"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _SensorStatus _temperatureStatusFor(double value) {
    if (value <= 0) {
      return const _SensorStatus(
        message: "Belum ada data suhu",
        color: Color(0xFF777A82),
      );
    }

    if (value < 24) {
      return const _SensorStatus(
        message: "Suhu terlalu rendah",
        color: Color(0xFF2D6CDF),
      );
    }

    if (value <= 28) {
      return const _SensorStatus(
        message: "Suhu ideal",
        color: Color(0xFF188A4A),
      );
    }

    return const _SensorStatus(
      message: "Suhu terlalu tinggi",
      color: AppColors.primary,
    );
  }
}

class _SoilCard extends StatelessWidget {
  const _SoilCard({required this.soil});

  final double soil;

  @override
  Widget build(BuildContext context) {
    final value = soil.clamp(0, 100).round();
    final pumpStatus = _pumpStatusForSoil(value);

    return _WhiteCard(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("TANAH", style: _sectionLabelStyle),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFF0D6D8),
                  color: AppColors.primary,
                ),
                Center(
                  child: Text(
                    "$value%",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Kelembapan",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            pumpStatus.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pumpStatus.color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  _SensorStatus _pumpStatusForSoil(int value) {
    if (value < 60) {
      return const _SensorStatus(
        message: "Tanah kering, pompa menyala",
        color: AppColors.primary,
      );
    }

    if (value <= 80) {
      return const _SensorStatus(
        message: "Kelembapan ideal, pompa mati",
        color: Color(0xFF188A4A),
      );
    }

    return const _SensorStatus(
      message: "Tanah terlalu basah, pompa mati",
      color: Color(0xFF2D6CDF),
    );
  }
}

class _SensorStatus {
  const _SensorStatus({required this.message, required this.color});

  final String message;
  final Color color;
}

class _ActiveDeviceCard extends StatelessWidget {
  const _ActiveDeviceCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("PERANGKAT", style: _sectionLabelStyle),
          const SizedBox(height: 14),
          Text(
            "$count",
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Sensor aktif",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            "Soil moisture dan DHT22",
            style: TextStyle(color: Color(0xFF777A82), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEDEEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetricValue extends StatelessWidget {
  const _MetricValue({
    required this.value,
    required this.label,
    this.status,
    this.statusColor,
  });

  final String value;
  final String label;
  final String? status;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF777A82), fontSize: 12),
        ),
        if (status != null) ...[
          const SizedBox(height: 6),
          Text(
            status!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: statusColor ?? const Color(0xFF777A82),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}

const _sectionLabelStyle = TextStyle(
  color: Color(0xFF777A82),
  fontSize: 11,
  fontWeight: FontWeight.w700,
);

const _sectionTitleStyle = TextStyle(
  color: Color(0xFF191A1F),
  fontSize: 18,
  fontWeight: FontWeight.w800,
);
