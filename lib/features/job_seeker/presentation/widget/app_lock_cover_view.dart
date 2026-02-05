import 'package:flutter/material.dart';

class AppLockCoverView extends StatelessWidget {
  final VoidCallback onUnlock;
  final VoidCallback onForgotPin;

  const AppLockCoverView({
    super.key,
    required this.onUnlock,
    required this.onForgotPin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: onUnlock,
                  icon: Icon(
                    Icons.lock_outline,
                    color: colorScheme.surface,
                    size: 18,
                  ),
                  label: Text(
                    'Unlock',
                    style: TextStyle(
                      color: colorScheme.surface,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onSurface,
                    minimumSize: const Size(140, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onForgotPin,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    minimumSize: const Size(140, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Forgot PIN?',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
