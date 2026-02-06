import 'package:flutter/material.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
            'https://api.uifaces.co/our-content/donated/x4_8P_NS.jpg',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hello',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Savannah Nguyen',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(10),
          child: AppSvgIcon(
            assetName: AppIcon.notification,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
