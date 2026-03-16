import 'package:flutter/material.dart';

class FormFieldLabel extends StatelessWidget {
  final String label;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final String? actionTooltip;

  const FormFieldLabel({
    super.key,
    required this.label,
    this.onAction,
    this.actionIcon,
    this.actionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        if (onAction != null)
          IconButton(
            onPressed: onAction,
            icon: Icon(
              actionIcon ?? Icons.auto_awesome_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
            tooltip: actionTooltip ?? 'AI Smart Fill',
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }
}
