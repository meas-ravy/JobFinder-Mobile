import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/core/theme/app_color.dart';

class RecruiterStatsPage extends StatefulWidget {
  const RecruiterStatsPage({super.key});

  @override
  State<RecruiterStatsPage> createState() => _RecruiterStatsPageState();
}

class _RecruiterStatsPageState extends State<RecruiterStatsPage> {
  int _segmentIndex = 0;

  final List<_CandidateStat> _candidates = const [
    _CandidateStat(
      role: 'Product designer',
      name: 'Akbar Rahman',
      percent: 78,
      color: AppColor.appliedLight,
    ),
    _CandidateStat(
      role: 'Product designer',
      name: 'Erman Ermin',
      percent: 80,
      color: AppColor.appliedLight,
    ),
    _CandidateStat(
      role: 'Product designer',
      name: 'Arfata Nayeem',
      percent: 70,
      color: AppColor.appliedLight,
    ),
    _CandidateStat(
      role: 'Product designer',
      name: 'Wasmihy Chy',
      percent: 60,
      color: AppColor.appliedLight,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColor.cardLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColor.cardBorderLight),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Stats',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Last 7 Months',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 14),
              _buildRadarCard(),
              const SizedBox(height: 16),
              _buildLegend(),
              const SizedBox(height: 20),
              _buildSegmentedControl(),
              const SizedBox(height: 16),
              ..._candidates.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCandidateTile(item),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarCard() {
    final labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    final dataSets = [
      _RadarDataSet(
        values: const [88, 92, 70, 68, 76, 80, 90],
        strokeColor: AppColor.appliedLight,
        fillColor: AppColor.appliedLight.withValues(alpha: 0.16),
      ),
      _RadarDataSet(
        values: const [62, 68, 50, 48, 55, 60, 65],
        strokeColor: AppColor.interviewLight,
        fillColor: AppColor.interviewLight.withValues(alpha: 0.16),
      ),
      _RadarDataSet(
        values: const [40, 46, 30, 28, 35, 38, 42],
        strokeColor: AppColor.confirmLight,
        fillColor: AppColor.confirmLight.withValues(alpha: 0.16),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.cardBorderLight),
      ),
      child: SizedBox(
        height: 240,
        child: _RadarChart(
          labels: labels,
          dataSets: dataSets,
          maxValue: 100,
          labelStyle: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColor.textMutedLight,
          ),
          gridColor: AppColor.cardBorderLight.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _LegendRow(
          color: AppColor.appliedLight,
          label: 'Applied',
          value: '1500',
        ),
        Divider(
          height: 16,
          thickness: 1,
          color: AppColor.cardBorderLight.withValues(alpha: 0.7),
        ),
        _LegendRow(
          color: AppColor.interviewLight,
          label: 'Interview',
          value: '750',
        ),
        Divider(
          height: 16,
          thickness: 1,
          color: AppColor.cardBorderLight.withValues(alpha: 0.7),
        ),
        _LegendRow(
          color: AppColor.confirmLight,
          label: 'Job Confirm',
          value: '180',
        ),
      ],
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.cardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.cardBorderLight),
      ),
      child: Row(
        children: [
          _SegmentItem(
            label: 'Applied',
            selected: _segmentIndex == 0,
            onTap: () => setState(() => _segmentIndex = 0),
          ),
          _SegmentItem(
            label: 'Interview',
            selected: _segmentIndex == 1,
            onTap: () => setState(() => _segmentIndex = 1),
          ),
          _SegmentItem(
            label: 'Confirm',
            selected: _segmentIndex == 2,
            onTap: () => setState(() => _segmentIndex = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateTile(_CandidateStat item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.cardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.cardBorderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.role,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          _ProgressRing(percent: item.percent, color: item.color),
        ],
      ),
    );
  }
}

class _RadarChart extends StatelessWidget {
  const _RadarChart({
    required this.labels,
    required this.dataSets,
    required this.maxValue,
    required this.labelStyle,
    required this.gridColor,
  });

  final List<String> labels;
  final List<_RadarDataSet> dataSets;
  final double maxValue;
  final TextStyle labelStyle;
  final Color gridColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: CustomPaint(
            size: Size.square(size),
            painter: _RadarChartPainter(
              labels: labels,
              dataSets: dataSets,
              maxValue: maxValue,
              labelStyle: labelStyle,
              gridColor: gridColor,
            ),
          ),
        );
      },
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({
    required this.labels,
    required this.dataSets,
    required this.maxValue,
    required this.labelStyle,
    required this.gridColor,
  });

  final List<String> labels;
  final List<_RadarDataSet> dataSets;
  final double maxValue;
  final TextStyle labelStyle;
  final Color gridColor;

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
        final value = dataSet.values[i].clamp(0, maxValue);
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
        final value = dataSet.values[i].clamp(0, maxValue);
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
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.dataSets != dataSets ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.labelStyle != labelStyle ||
        oldDelegate.gridColor != gridColor;
  }
}

class _RadarDataSet {
  const _RadarDataSet({
    required this.values,
    required this.strokeColor,
    required this.fillColor,
    // ignore: unused_element_parameter
    this.strokeWidth = 2,
  });

  final List<double> values;
  final Color strokeColor;
  final Color fillColor;
  final double strokeWidth;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF242C48) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF9AA4B8),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.percent, required this.color});

  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 4,
            backgroundColor: color.withValues(alpha: 0.2),
            color: color,
            strokeCap: StrokeCap.round,
          ),
          Text(
            '$percent%',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateStat {
  const _CandidateStat({
    required this.role,
    required this.name,
    required this.percent,
    required this.color,
  });

  final String role;
  final String name;
  final int percent;
  final Color color;
}
