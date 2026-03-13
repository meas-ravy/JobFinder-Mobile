import 'package:flutter/material.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';

class AppliedShimmer extends StatelessWidget {
  const AppliedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: 6,
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: 0.2),
      ),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerCircle(radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        ShimmerLoading(width: 120, height: 16),
                        ShimmerLoading(width: 50, height: 12),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const ShimmerLoading(width: 180, height: 12),
                    const SizedBox(height: 8),
                    const ShimmerLoading(width: 140, height: 14),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        ShimmerLoading(width: 80, height: 24, borderRadius: 20),
                        SizedBox(width: 8),
                        Spacer(),
                        ShimmerLoading(width: 16, height: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
