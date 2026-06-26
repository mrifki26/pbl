import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/notification_service.dart';
import '../../widgets/app_logo.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: NotificationService.instance,
        builder: (context, _) {
          final notifications = NotificationService.instance.items;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(),
                const SizedBox(height: 24),
                const Text(
                  "Notifikasi",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Pantau kondisi tanaman dan aktivitas perangkat secara realtime.",
                  style: TextStyle(color: Color(0xFF777A82)),
                ),
                const SizedBox(height: 22),
                _SectionHeader(
                  title: "Hari Ini",
                  action: notifications.isEmpty ? null : "TANDAI DIBACA",
                  onAction: NotificationService.instance.markAllRead,
                ),
                const SizedBox(height: 10),
                if (notifications.isEmpty)
                  const _EmptyNotification()
                else
                  ...notifications.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _NotificationCard(item: item),
                    ),
                  ),
                const SizedBox(height: 10),
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
                        "TIPS PANEN",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Optimalkan warna cabai",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Jaga penyiraman tetap stabil agar tanaman tidak stres.",
                        style: TextStyle(color: Colors.white, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
        _HeaderBadge(count: NotificationService.instance.unreadCount),
      ],
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.count});

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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyNotification extends StatelessWidget {
  const _EmptyNotification();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEDEEF2)),
      ),
      child: const Text(
        "Belum ada notifikasi. Data akan muncul otomatis saat sensor atau pompa berubah.",
        style: TextStyle(color: Color(0xFF777A82), height: 1.35),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final ChiliNotification item;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.type) {
      ChiliNotificationType.warning => Icons.priority_high_rounded,
      ChiliNotificationType.activity => Icons.water_drop_rounded,
      ChiliNotificationType.system => Icons.sensors_rounded,
    };
    final color = switch (item.type) {
      ChiliNotificationType.warning => AppColors.primary,
      ChiliNotificationType.activity => const Color(0xFF2F80ED),
      ChiliNotificationType.system => const Color(0xFF6B7A90),
    };
    final label = switch (item.type) {
      ChiliNotificationType.warning => "PERINGATAN",
      ChiliNotificationType.activity => "AKTIVITAS",
      ChiliNotificationType.system => "SISTEM",
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.read ? const Color(0xFFF8F8F9) : Colors.white,
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
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(item.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF777A82),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.body,
                  style: const TextStyle(
                    color: Color(0xFF777A82),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");

    return "$hour:$minute";
  }
}
