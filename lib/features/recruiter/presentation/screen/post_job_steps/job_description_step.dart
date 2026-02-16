import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'shared_widgets.dart';

class JobDescriptionStep extends StatelessWidget {
  const JobDescriptionStep({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final formState = FormBuilder.of(context);
    final category =
        formState?.fields['category']?.value as String? ?? 'Technology';

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
        FormTextInput(
          name: 'description',
          hint: 'Describe the role...',
          maxLines: 4,
          validators: [
            FormBuilderValidators.required(),
            FormBuilderValidators.minLength(30),
          ],
        ),
        const SizedBox(height: 20),
        FormListInput(
          name: 'responsibilities',
          hint: 'Type a responsibility and press enter...',
          label: 'Responsibilities',
          suggestions: _getResponsibilities(category),
          validators: [FormBuilderValidators.required()],
        ),
        const SizedBox(height: 20),
        FormListInput(
          name: 'requirements',
          hint: 'Type a requirement and press enter...',
          label: 'Requirements',
          suggestions: _getRequirements(category),
          validators: [FormBuilderValidators.required()],
        ),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Skills'),
        const SizedBox(height: 8),
        FormTextInput(
          name: 'skills',
          hint: 'e.g. Flutter, Dart, Firebase',
          maxLines: 2,
          validators: [FormBuilderValidators.required()],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  List<String> _getResponsibilities(String category) {
    switch (category) {
      case 'Technology':
        return [
          'Develop and maintain features',
          'Optimize app performance',
          'Collaborate with team',
          'Write clean code',
          'Fix critical bugs',
        ];
      case 'Marketing':
        return [
          'Manage social media',
          'Create marketing campaigns',
          'Analyze market trends',
          'Optimize SEO/SEM',
          'Coordinate with sales',
        ];
      case 'Design':
        return [
          'Create UI/UX designs',
          'Develop brand guidelines',
          'Produce visual assets',
          'Conduct user research',
          'Build interactive prototypes',
        ];
      case 'Finance':
        return [
          'Manage financial reports',
          'Conduct budget analysis',
          'Oversee tax compliance',
          'Prepare audits',
          'Evaluate investments',
        ];
      case 'Management':
        return [
          'Lead team projects',
          'Define strategic goals',
          'Evaluate performance',
          'Manage resources',
          'Improve workflows',
        ];
      default:
        return ['Task 1', 'Task 2'];
    }
  }

  List<String> _getRequirements(String category) {
    switch (category) {
      case 'Technology':
        return [
          '3+ years Flutter exp',
          'Strong Dart knowledge',
          'State management expertise',
          'RESTful API integration',
          'CI/CD experience',
        ];
      case 'Marketing':
        return [
          'Degree in Marketing',
          'Exp with Google Ads',
          'Strong communication',
          'Content creation skills',
          'Analytical mindset',
        ];
      case 'Design':
        return [
          'Expert in Figma/Adobe',
          'Portfolio of work',
          'Visual design degree',
          'Prototyping experience',
          'Attention to detail',
        ];
      case 'Finance':
        return [
          'CPA or equivalent',
          'Expert in Excel',
          'Financial modeling exp',
          'Auditing background',
          'High integrity',
        ];
      case 'Management':
        return [
          'MBA preferred',
          'Leadership experience',
          'Decision making skills',
          'Project management exp',
          'Mentoring ability',
        ];
      default:
        return ['Skill 1', 'Skill 2'];
    }
  }
}
