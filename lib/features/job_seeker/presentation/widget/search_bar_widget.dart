import 'package:flutter/material.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSearch;

  const SearchBarWidget({super.key, this.onFilterTap, this.onSearch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(color: theme.colorScheme.onSurface, width: 1),
        ),
        child: TextField(
          onChanged: onSearch,
          decoration: InputDecoration(
            hintText: 'Search for a job or company',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
              fontSize: 15,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: AppSvgIcon(
                assetName: AppIcon.search,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
            suffixIcon: IconButton(
              onPressed: onFilterTap,
              icon: const Icon(
                Icons.tune,
                color: AppColor.primaryDark,
                size: 24,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
