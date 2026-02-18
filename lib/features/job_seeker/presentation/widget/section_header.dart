import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllTap;

  const SectionHeader({super.key, required this.title, this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          if (onSeeAllTap != null)
            TextButton(
              onPressed: onSeeAllTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColor.primaryDark,
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'See All',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}
