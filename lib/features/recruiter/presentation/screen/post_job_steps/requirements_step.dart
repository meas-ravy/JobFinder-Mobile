import 'package:flutter/material.dart';
import 'shared_widgets.dart';

class RequirementsStep extends StatelessWidget {
  const RequirementsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requirements',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 24),
        const FormFieldLabel(label: 'Skills Required'),
        const SizedBox(height: 8),
        const FormTextInput(
          name: 'skills',
          hint: 'e.g. Flutter, Dart, Firebase',
        ),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Experience Level'),
        const SizedBox(height: 8),
        const FormTextInput(name: 'experience', hint: 'e.g. 2+ years'),
        const SizedBox(height: 32),
      ],
    );
  }
}
