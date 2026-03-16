import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/ai_assistant_provider.dart';

class PremiumPaywall extends HookConsumerWidget {
  final bool isDark;
  final VoidCallback? onSuccess;

  const PremiumPaywall({super.key, required this.isDark, this.onSuccess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumNotifier = ref.read(premiumStatusProvider.notifier);
    final isLoading = useState(false);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColor.backgroundColorDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          const Icon(Icons.auto_awesome, size: 64, color: AppColor.primaryDark),
          const SizedBox(height: 24),
          const Text(
            'Unlock AI Insights',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Get a detailed match score and personalized advice for every job using Gemini AI.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          _buildFeatureRow(Icons.check_circle, 'Personalized Match Score'),
          _buildFeatureRow(Icons.check_circle, 'Missing Skills Analysis'),
          _buildFeatureRow(Icons.check_circle, 'Resume Improvement Tips'),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading.value
                  ? null
                  : () async {
                      isLoading.value = true;
                      try {
                        // Perform the upgrade
                        await premiumNotifier.upgrade();

                        if (context.mounted) {
                          // Pop the bottom sheet
                          Navigator.pop(context);
                          // Trigger success callback
                          onSuccess?.call();
                        }
                      } finally {
                        if (context.mounted) {
                          isLoading.value = false;
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Upgrade to Premium - \$4.99/mo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
