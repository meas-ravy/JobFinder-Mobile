import 'package:flutter/material.dart';
import 'package:job_finder/features/recruiter/presentation/shared/dashed_rectpainter.dart';

class FormUploadArea extends StatelessWidget {
  const FormUploadArea({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, 160),
            painter: DashedRectPainter(
              color: colorScheme.primary.withValues(alpha: 0.3),
              strokeWidth: 1,
              gap: 4,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.file_upload_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Upload File',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    children: [
                      const TextSpan(text: 'Supported: '),
                      TextSpan(
                        text: '(png)  (Jpg)  (Svg)  (20mb)',
                        style: TextStyle(
                          color: colorScheme.primary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
