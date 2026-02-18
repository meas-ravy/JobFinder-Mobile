import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class JobDetailShimmer extends StatelessWidget {
  final bool isDark;

  const JobDetailShimmer({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[900]! : Colors.grey[200]!,
      highlightColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: List.generate(
                3,
                (index) => Container(
                  width: 100,
                  height: 30,
                  margin: const EdgeInsets.only(right: 12),
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(height: 200, width: double.infinity, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
