import 'package:flutter/material.dart';

class BuildExpanSection extends StatelessWidget {
  const BuildExpanSection({
    super.key,
    required this.title,
    required this.desc,
    required this.isExpanded,
    required this.child,
    required this.onToggle,
  });

  final String title, desc;
  final bool isExpanded;
  final Widget child;
  final Function() onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 25,
                      color: colorScheme.onSurface,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  desc,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: child,
          ),
      ],
    );
  }
}
