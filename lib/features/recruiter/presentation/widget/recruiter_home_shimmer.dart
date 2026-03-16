import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';

class RecruiterHomeShimmer extends StatelessWidget {
  const RecruiterHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColor.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: isDark
                  ? AppColor.cardDark
                  : colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLoading(width: 64, height: 64, borderRadius: 20),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 4),
                        ShimmerLoading(width: 140, height: 18),
                        SizedBox(height: 8),
                        ShimmerLoading(width: 100, height: 14),
                      ],
                    ),
                  ),
                  const ShimmerCircle(radius: 12),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                color: isDark
                    ? colorScheme.outline.withValues(alpha: 0.1)
                    : colorScheme.outline.withValues(alpha: 0.05),
              ),
              const SizedBox(height: 16),

              // Info Section
              const ShimmerLoading(width: 180, height: 16),
              const SizedBox(height: 12),
              const ShimmerLoading(width: 120, height: 22),
              const SizedBox(height: 20),

              // Tags Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  ShimmerLoading(width: 100, height: 32, borderRadius: 12),
                  SizedBox(width: 12),
                  ShimmerLoading(width: 100, height: 32, borderRadius: 12),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
