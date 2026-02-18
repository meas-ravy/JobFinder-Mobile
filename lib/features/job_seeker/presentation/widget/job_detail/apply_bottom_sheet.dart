import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/create_resume.dart';

class ApplyBottomSheet extends StatelessWidget {
  final bool isDark;

  const ApplyBottomSheet({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 40),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Apply Job',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF0F7FF),
                    foregroundColor: AppColor.primaryDark,
                    minimumSize: const Size(0, 56),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Apply with CV',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BuildTemplate(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 56),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Create CV',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
