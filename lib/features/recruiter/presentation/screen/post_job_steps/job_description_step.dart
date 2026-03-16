import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:job_finder/features/recruiter/presentation/shared/form_field_label.dart';
import 'package:job_finder/features/recruiter/presentation/shared/form_list_input.dart';
import 'package:job_finder/features/recruiter/presentation/shared/form_text_input.dart';

class JobDescriptionStep extends StatelessWidget {
  const JobDescriptionStep({
    super.key,
    this.onAIGenerate,
    this.onGenerateDescription,
    this.onGenerateResponsibilities,
    this.onGenerateRequirements,
    this.onGenerateSkills,
  });

  final VoidCallback? onAIGenerate;
  final VoidCallback? onGenerateDescription;
  final VoidCallback? onGenerateResponsibilities;
  final VoidCallback? onGenerateRequirements;
  final VoidCallback? onGenerateSkills;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final formState = FormBuilder.of(context);
    final category =
        formState?.fields['category']?.value as String? ?? 'Technology';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Job Details',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            if (onAIGenerate != null)
              TextButton.icon(
                onPressed: onAIGenerate,
                label: const Text('Fill All'),
                icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        FormFieldLabel(
          label: 'Description',
          onAction: onGenerateDescription,
          actionTooltip: 'Generate Description Only',
        ),
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
          onAction: onGenerateResponsibilities,
          suggestions: _getResponsibilities(category),
          validators: [FormBuilderValidators.required()],
        ),
        const SizedBox(height: 20),
        FormListInput(
          name: 'requirements',
          hint: 'Type a requirement and press enter...',
          label: 'Requirements',
          onAction: onGenerateRequirements,
          suggestions: _getRequirements(category),
          validators: [FormBuilderValidators.required()],
        ),
        const SizedBox(height: 20),
        FormFieldLabel(
          label: 'Skills',
          onAction: onGenerateSkills,
          actionTooltip: 'Suggest Skills Only',
        ),
        const SizedBox(height: 8),
        FormTextInput(
          name: 'skills',
          hint: 'Enter skills',
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
      case 'Engineering':
        return [
          'Develop, implement, and maintain application features',
          'Optimize application performance and scalability',
          'Collaborate with cross-functional teams (design, QA, product)',
          'Write clean, maintainable, and well-documented code',
          'Identify, troubleshoot, and fix critical bugs and issues',
        ];
      case 'Marketing':
      case 'Sales':
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
      case 'Healthcare':
        return [
          'Patient care and monitoring',
          'Maintain medical records',
          'Administer medications',
          'Collaborate with health team',
          'Ensure safety protocols',
        ];
      case 'Education':
        return [
          'Develop lesson plans',
          'Evaluate student progress',
          'Teach core subjects',
          'Manage classroom behavior',
          'Engage with parents',
        ];
      case 'Operations':
      case 'HumanResources':
        return [
          'Streamline workflows',
          'Manage internal resources',
          'Ensure compliance',
          'Handle recruitment',
          'Coordinate team activities',
        ];
      default:
        return [
          'Perform daily tasks',
          'Collaborate with team',
          'Report to supervisor',
          'Maintain work quality',
          'Follow safety guidelines',
        ];
    }
  }

  List<String> _getRequirements(String category) {
    switch (category) {
      case 'Technology':
      case 'Engineering':
        return [
          '3+ years technical exp',
          'Relevant degree',
          'Problem solving skills',
          'Team player mindset',
          'CI/CD experience',
        ];
      case 'Marketing':
      case 'Sales':
        return [
          'Degree in relevant field',
          'Strong communication',
          'Analytical mindset',
          'Digital tool proficiency',
          'Target-driven attitude',
        ];
      case 'Design':
        return [
          'Expert in design tools',
          'Portfolio of work',
          'Visual design degree',
          'Attention to detail',
          'Creative thinking',
        ];
      case 'Finance':
      case 'Legal':
        return [
          'Professional certification',
          'Relevant degree',
          'High integrity',
          'Analytical skills',
          'Industry experience',
        ];
      case 'Healthcare':
        return [
          'Valid medical license',
          'Clinical experience',
          'Patience and empathy',
          'Strong observation',
          'Relevant degree',
        ];
      case 'Education':
        return [
          'Teaching certificate',
          'Subject expertise',
          'Classroom management',
          'Organizational ability',
          'Relevant degree',
        ];
      default:
        return [
          'Relevant experience',
          'Strong communication',
          'Positive attitude',
          'Reliability',
          'Willingness to learn',
        ];
    }
  }
}
