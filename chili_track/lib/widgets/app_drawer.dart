import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../pages/monitoring/monitoring_page.dart';
import '../pages/control/control_page.dart';
import '../pages/device/device_page.dart';
import '../pages/notification/notification_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(gradient: AppColors.greenGradient),
            child: const Center(
              child: Text(
                "ChiliTrack 🌶️",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),

          _menu(context, "Monitoring", Icons.monitor, const MonitoringPage()),
          _menu(context, "Control", Icons.settings, const ControlPage()),
          _menu(context, "Device", Icons.devices, const DevicePage()),
          _menu(
            context,
            "Notifications",
            Icons.notifications,
            const NotificationPage(),
          ),
        ],
      ),
    );
  }

  Widget _menu(context, title, icon, page) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
