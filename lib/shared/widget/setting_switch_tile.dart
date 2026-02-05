import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    this.icon,
    this.iconData,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.onTap,
  }) : assert(
         icon != null || iconData != null,
         'Either icon or iconData must be provided',
       );

  final String? icon;
  final IconData? iconData;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      splashColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
      leading: icon != null
          ? AppSvgIcon(
              assetName: icon!,
              size: 24,
              color: colorScheme.onSurface.withValues(alpha: 0.75),
            )
          : Icon(
              iconData,
              size: 26,
              color: colorScheme.onSurface.withValues(alpha: 0.75),
            ),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        // ignore: deprecated_member_use
        activeColor: AppColor.primaryLight,
      ),
    );
  }
}
