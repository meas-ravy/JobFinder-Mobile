import 'package:flutter/material.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';
import 'package:job_finder/core/theme/app_color.dart';

class HomeBannerShimmer extends StatelessWidget {
  final bool isDark;
  const HomeBannerShimmer({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: isDark ? AppColor.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLoading(
                      width: double.infinity,
                      height: 22,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 10),
                    const ShimmerLoading(
                      width: 140,
                      height: 22,
                      borderRadius: 4,
                    ),
                    const Spacer(),
                    const ShimmerLoading(
                      width: 110,
                      height: 44,
                      borderRadius: 22,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              const ShimmerLoading(width: 100, height: 100, borderRadius: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class RecommendedJobShimmer extends StatelessWidget {
  final bool isDark;
  const RecommendedJobShimmer({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 4),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColor.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLoading(
                      width: 56,
                      height: 56,
                      borderRadius: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerLoading(
                            width: 150,
                            height: 20,
                            borderRadius: 10,
                          ),
                          SizedBox(height: 8),
                          ShimmerLoading(
                            width: 100,
                            height: 16,
                            borderRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const ShimmerLoading(
                      width: 24,
                      height: 24,
                      borderRadius: 6,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
                const SizedBox(height: 12),
                const ShimmerLoading(width: 120, height: 18, borderRadius: 8),
                const SizedBox(height: 12),
                const ShimmerLoading(width: 180, height: 22, borderRadius: 10),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    ShimmerLoading(width: 80, height: 32, borderRadius: 10),
                    SizedBox(width: 8),
                    ShimmerLoading(width: 70, height: 32, borderRadius: 10),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RecentJobShimmer extends StatelessWidget {
  final bool isDark;
  const RecentJobShimmer({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColor.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLoading(
                      width: 56,
                      height: 56,
                      borderRadius: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerLoading(
                            width: 180,
                            height: 20,
                            borderRadius: 10,
                          ),
                          SizedBox(height: 8),
                          ShimmerLoading(
                            width: 120,
                            height: 16,
                            borderRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const ShimmerLoading(
                      width: 24,
                      height: 24,
                      borderRadius: 6,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
                const SizedBox(height: 12),
                const ShimmerLoading(width: 100, height: 16, borderRadius: 8),
                const SizedBox(height: 12),
                const ShimmerLoading(width: 150, height: 20, borderRadius: 10),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    ShimmerLoading(width: 80, height: 28, borderRadius: 8),
                    SizedBox(width: 8),
                    ShimmerLoading(width: 70, height: 28, borderRadius: 8),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
