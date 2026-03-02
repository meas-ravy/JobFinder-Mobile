import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';

class JobDetailShimmer extends StatelessWidget {
  final bool isDark;
  const JobDetailShimmer({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Info Card Shimmer
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColor.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  // Logo
                  const ShimmerLoading(width: 80, height: 80, borderRadius: 20),
                  const SizedBox(height: 16),

                  // Title
                  const ShimmerLoading(
                    width: 200,
                    height: 26,
                    borderRadius: 12,
                  ),
                  const SizedBox(height: 10),

                  // Company
                  const ShimmerLoading(width: 120, height: 18, borderRadius: 8),
                  const SizedBox(height: 20),

                  Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
                  const SizedBox(height: 20),

                  // Location
                  const ShimmerLoading(width: 150, height: 16, borderRadius: 8),
                  const SizedBox(height: 12),

                  // Salary
                  const ShimmerLoading(
                    width: 180,
                    height: 20,
                    borderRadius: 10,
                  ),
                  const SizedBox(height: 16),

                  // Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      ShimmerLoading(width: 80, height: 32, borderRadius: 10),
                      SizedBox(width: 10),
                      ShimmerLoading(width: 70, height: 32, borderRadius: 10),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date
                  const ShimmerLoading(width: 140, height: 14, borderRadius: 6),
                ],
              ),
            ),
          ),

          // 2. TabBar Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  _buildTabShimmer('Description', 90, true),
                  _buildTabShimmer('Responsibilities', 120, false),
                  _buildTabShimmer('Requirements', 110, false),
                  _buildTabShimmer('Skills', 60, false),
                  _buildTabShimmer('Perks', 60, false),
                  _buildTabShimmer('Company', 80, false),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 3,
              width: 90,
              decoration: BoxDecoration(
                color: AppColor.primaryDark.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 3. Tab Body Content Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(width: 160, height: 22, borderRadius: 10),
                const SizedBox(height: 20),

                // Content Paragraph lines
                const ShimmerLoading(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 8,
                ),
                const SizedBox(height: 12),
                const ShimmerLoading(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 8,
                ),
                const SizedBox(height: 12),
                const ShimmerLoading(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 8,
                ),
                const SizedBox(height: 12),
                const ShimmerLoading(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 8,
                ),
                const SizedBox(height: 12),
                ShimmerLoading(
                  width: screenWidth * 0.7,
                  height: 16,
                  borderRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabShimmer(String label, double width, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ShimmerLoading(width: width, height: 20, borderRadius: 4)],
      ),
    );
  }
}
