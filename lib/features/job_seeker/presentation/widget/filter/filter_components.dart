import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';

class SalaryBadge extends StatelessWidget {
  final String label;

  const SalaryBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.primaryDark.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColor.primaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class CustomRangeThumbShape extends RangeSliderThumbShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(22, 22);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool? isDiscrete,
    bool? isEnabled,
    bool? isOnTop,
    bool? isPressed,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, 11, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..color = AppColor.primaryDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }
}
