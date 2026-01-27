import 'package:flutter/material.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class DangerTile extends StatelessWidget {
  const DangerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final danger = colorScheme.error;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: AppSvgIcon(assetName: icon, size: 24, color: danger),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: danger,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: danger.withValues(alpha: 0.7)),
      onTap: onTap,
    );
  }
}
