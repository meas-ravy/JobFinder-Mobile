import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';

class ApplicationDetailShimmer extends StatelessWidget {
  const ApplicationDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Application Details',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerCircle(radius: 40),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerLoading(width: 180, height: 28),
                      SizedBox(height: 8),
                      ShimmerLoading(width: 140, height: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const ShimmerLoading(width: 120, height: 18),
            const SizedBox(height: 12),
            ShimmerLoading(
              width: double.infinity,
              height: 80,
              borderRadius: 16,
            ),
            const SizedBox(height: 32),
            const ShimmerLoading(width: 150, height: 18),
            const SizedBox(height: 16),
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: const [
                    ShimmerCircle(radius: 10),
                    SizedBox(width: 12),
                    ShimmerLoading(width: 80, height: 14),
                    Spacer(),
                    ShimmerLoading(width: 100, height: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              children: const [
                Expanded(child: ShimmerLoading(width: 100, height: 50)),
                SizedBox(width: 16),
                Expanded(child: ShimmerLoading(width: 100, height: 50)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
