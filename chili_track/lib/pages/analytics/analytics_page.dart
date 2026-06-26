import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/api_service.dart';
import '../../widgets/app_logo.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final List<FlSpot> _temperatureSpots = [];
  final List<FlSpot> _soilSpots = [];
  Timer? _timer;
  int _tick = 0;
  double _latestTemp = 0;
  double _latestSoil = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final tempData = await ApiService.getLatestTemperature();
      final soilData = await ApiService.getLatestSoil();
      final temp = (tempData['temperature'] as num).toDouble();
      final soil = (soilData['soilMoisture'] as num).toDouble();

      if (!mounted) return;
      setState(() {
        _latestTemp = temp;
        _latestSoil = soil;
        _temperatureSpots.add(FlSpot(_tick.toDouble(), temp));
        _soilSpots.add(FlSpot(_tick.toDouble(), soil));
        _tick++;
        if (_temperatureSpots.length > 10) {
          _temperatureSpots.removeAt(0);
        }
        if (_soilSpots.length > 10) {
          _soilSpots.removeAt(0);
        }
      });
    } catch (_) {
      // Keep the last visible values when the service is temporarily unreachable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final tempSpots = _temperatureSpots.isEmpty
        ? const [FlSpot(0, 0), FlSpot(1, 0)]
        : _temperatureSpots;
    final soilSpots = _soilSpots.isEmpty
        ? const [FlSpot(0, 0), FlSpot(1, 0)]
        : _soilSpots;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const SizedBox(height: 22),
            const Text(
              "Statistik",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              "Analisis sensor dari data terbaru perangkat.",
              style: TextStyle(color: Color(0xFF777A82)),
            ),
            const SizedBox(height: 18),
            _ChartCard(
              title: "Tren Suhu",
              subtitle: "Data sensor DHT22",
              spots: tempSpots,
              maxY: 45,
              color: AppColors.primary,
              unit: "C",
            ),
            const SizedBox(height: 10),
            _ChartCard(
              title: "Tren Kelembapan Tanah",
              subtitle: "Data sensor soil moisture",
              spots: soilSpots,
              maxY: 100,
              color: const Color(0xFF2F80ED),
              unit: "%",
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.thermostat_rounded,
                    label: "Rata-rata Suhu",
                    value: "${_latestTemp.toStringAsFixed(1)}C",
                    note: _latestTemp > 32 ? "Panas" : "Stabil",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.water_drop_rounded,
                    label: "Kelembapan Tanah",
                    value: "${_latestSoil.toStringAsFixed(0)}%",
                    note: _latestSoil < 40 ? "Rendah" : "Stabil",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.redGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _latestSoil < 40
                    ? "Peringatan: kelembapan tanah rendah. Segera lakukan penyiraman."
                    : "Tanaman dalam kondisi baik. Pertahankan jadwal penyiraman saat ini.",
                style: const TextStyle(color: Colors.white, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.spots,
    required this.maxY,
    required this.color,
    required this.unit,
  });

  final String title;
  final String subtitle;
  final List<FlSpot> spots;
  final double maxY;
  final Color color;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final latest = spots.isEmpty ? 0 : spots.last.y;

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _cardTitleStyle),
                    const SizedBox(height: 2),
                    Text(subtitle, style: _smallMutedStyle),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "${latest.toStringAsFixed(1)}$unit",
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 190,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppLogo(size: 38),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            "ChiliTrack",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Icon(Icons.notifications_none_rounded, color: Color(0xFF9AA6B8)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
  });

  final IconData icon;
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE5E6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            style: _smallMutedStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          Text(
            note,
            style: const TextStyle(color: Color(0xFF777A82), fontSize: 11),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEDEEF2)),
      ),
      child: child,
    );
  }
}

const _cardTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w800,
  color: Color(0xFF191A1F),
);

const _smallMutedStyle = TextStyle(
  color: Color(0xFF777A82),
  fontSize: 11,
  fontWeight: FontWeight.w600,
);
