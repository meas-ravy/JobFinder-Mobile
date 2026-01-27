import 'package:flutter/material.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, required this.textTheme});
  final String title;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: AppSvgIcon(
        assetName: icon,
        size: 24,
        color: colorScheme.onSurface.withValues(alpha: 0.75),
      ),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                trailingText!,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Icon(
            Icons.chevron_right,
            color: colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
