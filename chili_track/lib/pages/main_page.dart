import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../services/notification_service.dart';
import 'dashboard/dashboard_page.dart';
import 'analytics/analytics_page.dart';
import 'notification/notification_page.dart';
import 'profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  final pages = [
    const DashboardPage(),
    const AnalyticsPage(),
    const NotificationPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    NotificationService.instance.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: AnimatedBuilder(
        animation: NotificationService.instance,
        builder: (context, _) {
          final unread = NotificationService.instance.unreadCount;

          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: index,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: const Color(0xFF9AA6B8),
            selectedFontSize: 11,
            unselectedFontSize: 10,
            onTap: (i) => setState(() => index = i),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: "Monitoring",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.show_chart_rounded),
                label: "Statistik",
              ),
              BottomNavigationBarItem(
                icon: _NavBadge(
                  count: unread,
                  child: const Icon(Icons.notifications_none_rounded),
                ),
                label: "Notifikasi",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                label: "Profil",
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  const _NavBadge({required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -8,
          top: -7,
          child: Container(
            constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              count > 9 ? "9+" : "$count",
              style: const TextStyle(color: Colors.white, fontSize: 9),
            ),
          ),
        ),
      ],
    );
  }
}
