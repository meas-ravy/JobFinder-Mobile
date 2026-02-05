import 'package:flutter/material.dart';

class AppLockRecoveryOverlay extends StatelessWidget {
  final String recoveryQuestion;
  final TextEditingController controller;
  final VoidCallback onDismiss;
  final VoidCallback onVerify;

  const AppLockRecoveryOverlay({
    super.key,
    required this.recoveryQuestion,
    required this.controller,
    required this.onDismiss,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Positioned.fill(
      child: Stack(
        children: [
          // Backdrop with tap-to-close
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              color: colorScheme.surface.withValues(alpha: 0.45),
            ),
          ),
          // Dialog Content
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.surface.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Question',
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    recoveryQuestion,
                    style: textTheme.bodyLarge?.copyWith(
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Enter your answer',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colorScheme.surfaceContainerHigh.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: onVerify,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Verify Identity',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
