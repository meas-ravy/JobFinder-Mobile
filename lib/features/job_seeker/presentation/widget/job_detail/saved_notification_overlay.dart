import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';

class SavedNotificationOverlay {
  static void show(BuildContext context, bool isDark, bool isSaved) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColor.primaryDark.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSaved ? AppColor.primaryDark : Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSaved ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  isSaved ? 'Job Saved!' : 'Job Unsaved',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
