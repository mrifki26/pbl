import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/api_service.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  late Future<_PumpDashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_PumpDashboardData> _loadData() async {
    final results = await Future.wait([
      ApiService.getStatus(),
      ApiService.getPumpDevices(),
      ApiService.getPumpHistory(),
    ]);

    return _PumpDashboardData(
      status: Map<String, dynamic>.from(results[0] as Map),
      devices: List<Map<String, dynamic>>.from(
        (results[1] as List).map((item) => Map<String, dynamic>.from(item)),
      ),
      history: List<Map<String, dynamic>>.from(
        (results[2] as List).map((item) => Map<String, dynamic>.from(item)),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _loadData());
    await _future;
  }

  Future<void> _setPump(bool pumpOn) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (pumpOn) {
        await ApiService.wateringOn();
      } else {
        await ApiService.wateringOff();
      }
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text("Gagal mengubah status pompa")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FutureBuilder<_PumpDashboardData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorState(onRetry: _refresh);
            }

            final data = snapshot.data!;
            final pumpOn = data.status["status"] == true;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
                children: [
                  const Text(
                    "Data Pompa",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Status, perangkat, dan riwayat kontrol pompa.",
                    style: TextStyle(color: Color(0xFF7A8190), fontSize: 14),
                  ),
                  const SizedBox(height: 22),
                  _StatusCard(pumpOn: pumpOn, onChanged: _setPump),
                  const SizedBox(height: 18),
                  _SectionHeader(
                    title: "Perangkat Pompa",
                    action: "${data.devices.length} perangkat",
                  ),
                  const SizedBox(height: 10),
                  if (data.devices.isEmpty)
                    const _EmptyCard(text: "Belum ada perangkat pompa.")
                  else
                    ...data.devices.map(_DeviceCard.new),
                  const SizedBox(height: 18),
                  _SectionHeader(
                    title: "Riwayat Kontrol",
                    action: "${data.history.length} terbaru",
                  ),
                  const SizedBox(height: 10),
                  if (data.history.isEmpty)
                    const _EmptyCard(text: "Belum ada riwayat kontrol.")
                  else
                    ...data.history.map(_HistoryTile.new),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PumpDashboardData {
  const _PumpDashboardData({
    required this.status,
    required this.devices,
    required this.history,
  });

  final Map<String, dynamic> status;
  final List<Map<String, dynamic>> devices;
  final List<Map<String, dynamic>> history;
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.pumpOn, required this.onChanged});

  final bool pumpOn;
  final Future<void> Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: pumpOn ? AppColors.greenGradient : AppColors.redGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              pumpOn ? Icons.water_drop : Icons.water_drop_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "STATUS POMPA",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  pumpOn ? "Pompa aktif" : "Pompa mati",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: pumpOn,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white38,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white38,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        Text(
          action,
          style: const TextStyle(
            color: Color(0xFF7A8190),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard(this.device);

  final Map<String, dynamic> device;

  @override
  Widget build(BuildContext context) {
    final active = device["active"] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.memory_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(device["name"], "Pompa"),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_text(device["deviceCode"], "-")} - ${_text(device["location"], "-")}",
                  style: const TextStyle(color: Color(0xFF7A8190)),
                ),
              ],
            ),
          ),
          _StatusPill(active: active),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile(this.item);

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final pumpOn = item["pumpOn"] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: pumpOn ? const Color(0xFFE2F5E9) : const Color(0xFFFFE4E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              pumpOn ? Icons.power_settings_new : Icons.power_off_rounded,
              color: pumpOn ? AppColors.normal : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(item["message"], pumpOn ? "Pump ON" : "Pump OFF"),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_text(item["deviceCode"], "-")} - ${_formatDate(item["controlledAt"])}",
                  style: const TextStyle(color: Color(0xFF7A8190), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE2F5E9) : const Color(0xFFFFE4E8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        active ? "Aktif" : "Nonaktif",
        style: TextStyle(
          color: active ? AppColors.normal : AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF7A8190))),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.primary, size: 42),
            const SizedBox(height: 12),
            const Text(
              "Data pompa belum bisa dimuat",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              "Pastikan control-service aktif dan token login masih valid.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7A8190)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Coba lagi"),
            ),
          ],
        ),
      ),
    );
  }
}

String _text(dynamic value, String fallback) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String _formatDate(dynamic value) {
  final text = _text(value, "-");
  if (text == "-") return text;
  return text.replaceFirst("T", " ");
}
