import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/app_logo.dart';

class DeviceManagementPage extends StatelessWidget {
  const DeviceManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  const AppLogo(size: 34),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Manajemen Perangkat",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.redGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PERANGKAT UTAMA",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "ESP32 ChiliTrack Node",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Device ID: 1 | WiFi: Admin | Status: Aktif",
                      style: TextStyle(color: Colors.white, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const _SpecCard(
                icon: Icons.grass_rounded,
                title: "Sensor Kelembapan Tanah",
                subtitle: "Soil moisture analog",
                specs: [
                  "Pin data: GPIO 32",
                  "Kalibrasi kering: 3500",
                  "Kalibrasi basah: 1550",
                  "Ambang penyiraman: 60%",
                ],
              ),
              const _SpecCard(
                icon: Icons.thermostat_rounded,
                title: "Sensor Suhu",
                subtitle: "DHT22",
                specs: [
                  "Pin data: GPIO 4",
                  "Data dikirim ke temperature-service",
                  "Interval baca mengikuti loop ESP32",
                ],
              ),
              const _SpecCard(
                icon: Icons.water_drop_rounded,
                title: "Pompa Air",
                subtitle: "Relay aktif LOW",
                specs: [
                  "Pin relay: GPIO 33",
                  "PUMP_ON: LOW",
                  "PUMP_OFF: HIGH",
                  "Otomatis aktif saat tanah < 60%",
                ],
              ),
              const _SpecCard(
                icon: Icons.cloud_upload_rounded,
                title: "Koneksi Backend",
                subtitle: "HTTP dari aplikasi ke API Gateway",
                specs: [
                  "Gateway: API Gateway",
                  "Auth: /api/auth",
                  "Soil: /api/soil",
                  "Temperature: /api/temperature",
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecCard extends StatelessWidget {
  const _SpecCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.specs,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> specs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEDEEF2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5E6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF777A82)),
                ),
                const SizedBox(height: 10),
                ...specs.map(
                  (spec) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(
                            Icons.circle,
                            size: 6,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            spec,
                            style: const TextStyle(height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
