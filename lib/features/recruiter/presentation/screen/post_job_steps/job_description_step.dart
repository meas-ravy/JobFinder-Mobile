import 'package:flutter/material.dart';
import 'shared_widgets.dart';

class JobDescriptionStep extends StatelessWidget {
  const JobDescriptionStep({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Description',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 24),
        const FormFieldLabel(label: 'Description'),
        const SizedBox(height: 8),
        const FormTextInput(
          name: 'description',
          hint: 'Describe the role and responsibilities...',
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
