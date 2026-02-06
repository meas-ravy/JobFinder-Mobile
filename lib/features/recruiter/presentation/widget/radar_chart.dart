import 'dart:math';
import 'package:flutter/material.dart';

class RadarChart extends StatelessWidget {
  const RadarChart({
    super.key,
    required this.labels,
    required this.dataSets,
    required this.maxValue,
    required this.labelStyle,
    required this.gridColor,
    this.animationValue = 1.0,
  });

  final List<String> labels;
  final List<RadarDataSet> dataSets;
  final double maxValue;
  final TextStyle? labelStyle;
  final Color gridColor;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: CustomPaint(
            size: Size.square(size),
            painter: RadarChartPainter(
              labels: labels,
              dataSets: dataSets,
              maxValue: maxValue,
              labelStyle: labelStyle,
              gridColor: gridColor,
              animationValue: animationValue,
            ),
          ),
        );
      },
    );
  }
}

class RadarChartPainter extends CustomPainter {
  RadarChartPainter({
    required this.labels,
    required this.dataSets,
    required this.maxValue,
    required this.labelStyle,
    required this.gridColor,
    required this.animationValue,
  });

  final List<String> labels;
  final List<RadarDataSet> dataSets;
  final double maxValue;
  final TextStyle? labelStyle;
  final Color gridColor;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (min(size.width, size.height) / 2) - 20;
    final step = (2 * pi) / labels.length;
    const startAngle = -pi / 2;

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = gridColor
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = gridColor.withValues(alpha: 0.7)
      ..strokeWidth = 1;

    const tickCount = 4;
    for (int tick = 1; tick <= tickCount; tick++) {
      final tickRadius = radius * (tick / tickCount);
      final path = Path();
      for (int i = 0; i < labels.length; i++) {
        final angle = startAngle + (step * i);
        final point =
            center + Offset(cos(angle) * tickRadius, sin(angle) * tickRadius);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (int i = 0; i < labels.length; i++) {
      final angle = startAngle + (step * i);
      final point = center + Offset(cos(angle) * radius, sin(angle) * radius);
      canvas.drawLine(center, point, axisPaint);
    }

    for (final dataSet in dataSets) {
      final path = Path();
      for (int i = 0; i < labels.length; i++) {
        final value = dataSet.values[i].clamp(0, maxValue) * animationValue;
        final valueRadius = radius * (value / maxValue);
        final angle = startAngle + (step * i);
        final point =
            center + Offset(cos(angle) * valueRadius, sin(angle) * valueRadius);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();

      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = dataSet.fillColor;
      canvas.drawPath(path, fillPaint);

      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = dataSet.strokeColor
        ..strokeWidth = dataSet.strokeWidth;
      canvas.drawPath(path, strokePaint);

      for (int i = 0; i < labels.length; i++) {
        final value = dataSet.values[i].clamp(0, maxValue) * animationValue;
        final valueRadius = radius * (value / maxValue);
        final angle = startAngle + (step * i);
        final point =
            center + Offset(cos(angle) * valueRadius, sin(angle) * valueRadius);
        canvas.drawCircle(point, 2.5, strokePaint);
      }
    }

    for (int i = 0; i < labels.length; i++) {
      final angle = startAngle + (step * i);
      final labelPoint =
          center +
          Offset(cos(angle) * (radius + 16), sin(angle) * (radius + 16));
      final textPainter = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          labelPoint.dx - (textPainter.width / 2),
          labelPoint.dy - (textPainter.height / 2),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.dataSets != dataSets ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.labelStyle != labelStyle ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.animationValue != animationValue;
  }
}

class RadarDataSet {
  const RadarDataSet({
    required this.values,
    required this.strokeColor,
    required this.fillColor,
    this.strokeWidth = 2,
  });

  final List<double> values;
  final Color strokeColor;
  final Color fillColor;
  final double strokeWidth;
}
