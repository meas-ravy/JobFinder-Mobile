import 'package:flutter/material.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:job_finder/shared/widget/zomtap_animation.dart';

class RoleSelectWidget extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String subtitle;
  final String icon;
  final Color bagColor, iconColor;
  final VoidCallback? onTap;

  const RoleSelectWidget({
    super.key,
    required this.isSelected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bagColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ZomtapAnimation(
      onTap: onTap,
      child: Container(
        height: 250,
        width: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.08),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: bagColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppSvgIcon(assetName: icon, color: iconColor),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 11),

            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
