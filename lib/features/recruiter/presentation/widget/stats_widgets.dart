import 'package:flutter/material.dart';

class LegendRow extends StatelessWidget {
  const LegendRow({
    super.key,
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 11),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class SegmentItem extends StatelessWidget {
  const SegmentItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.surfaceContainerHighest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.percent,
    required this.color,
    this.count,
  });

  final int percent;
  final Color color;
  final String? count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 54,
      height: 54,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: percent / 100),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 43,
                height: 43,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 3,
                  backgroundColor: colorScheme.outlineVariant.withValues(
                    alpha: 0.1,
                  ),
                  color: color,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                count ?? '${(value * 100).toInt()}%',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
