import 'package:flutter/material.dart';

class AnimatedNumber extends StatefulWidget {
  final double value;
  final String suffix;

  const AnimatedNumber({super.key, required this.value, this.suffix = ""});

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber> {
  double oldValue = 0;

  @override
  void didUpdateWidget(covariant AnimatedNumber oldWidget) {
    oldValue = oldWidget.value;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: oldValue, end: widget.value),
      duration: const Duration(milliseconds: 700),
      builder: (context, value, child) {
        return Text(
          "${value.toStringAsFixed(1)}${widget.suffix}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
