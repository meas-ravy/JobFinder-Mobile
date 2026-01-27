import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String icon;
  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

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
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColor.primaryLight,
      ),
    );
  }
}
