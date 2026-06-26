import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'animated_number.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    bool isDanger = title == "Soil" && value < 30;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDanger ? AppColors.redGradient : AppColors.greenGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white70)),
            AnimatedNumber(value: value, suffix: title == "Temp" ? "°C" : "%"),
          ],
        ),
      ),
    );
  }
}
