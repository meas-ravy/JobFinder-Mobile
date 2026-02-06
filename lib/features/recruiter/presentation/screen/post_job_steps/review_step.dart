import 'package:flutter/material.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Post',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.assignment_turned_in_outlined,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Ready to Post?',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please review all the information you have entered. You can go back to any step to make changes.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
