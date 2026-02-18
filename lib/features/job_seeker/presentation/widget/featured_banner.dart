import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';

class FeaturedBanner extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final String? imageUrl;

  const FeaturedBanner({
    super.key,
    required this.title,
    required this.buttonText,
    this.onButtonPressed,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4B8EFF), Color(0xFF5FA3FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryDark.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Opacity(
                  opacity: 0.1,
                  child: Image.network(
                    'https://www.transparenttextures.com/patterns/cubes.png',
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColor.primaryDark,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Image
                if (imageUrl != null)
                  Image.network(
                    imageUrl!,
                    width: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 60,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
