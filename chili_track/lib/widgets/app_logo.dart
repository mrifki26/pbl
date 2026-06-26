import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.size, this.padding = 0});

  final double size;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Image.asset(
          "assets/logo/image.png",
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.local_florist_rounded,
              color: Color(0xFFC91524),
            );
          },
        ),
      ),
    );
  }
}
