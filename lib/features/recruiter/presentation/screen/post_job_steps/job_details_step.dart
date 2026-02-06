import 'package:flutter/material.dart';
import 'shared_widgets.dart';

class JobDetailsStep extends StatelessWidget {
  const JobDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Details',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 24),
        const FormFieldLabel(label: 'Job Title'),
        const SizedBox(height: 8),
        const FormTextInput(name: 'job_title', hint: 'Enter job title'),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Employment Type'),
        const SizedBox(height: 8),
        const FormTextInput(
          name: 'employment_type',
          hint: 'e.g. Full-time, Part-time',
        ),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Salary Range'),
        const SizedBox(height: 8),
        FormTextInput(name: 'salary', hint: 'e.g. \$50 - \$80k'),
        const SizedBox(height: 32),
      ],
    );
  }
}
