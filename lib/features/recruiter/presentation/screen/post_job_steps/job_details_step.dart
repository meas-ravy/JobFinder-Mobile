import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
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
        FormTextInput(
          name: 'title',
          hint: 'Enter job title',
          validators: [
            FormBuilderValidators.required(),
            FormBuilderValidators.minLength(5),
          ],
        ),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Category'),
        const SizedBox(height: 8),
        FormDropdownInput(
          name: 'category',
          hint: 'Select Category',
          items: ['Technology', 'Marketing', 'Design', 'Finance', 'Management'],
          icon: Icons.category_rounded,
          validators: [FormBuilderValidators.required()],
        ),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Location'),
        const SizedBox(height: 8),
        FormTextInput(
          name: 'location',
          hint: 'Phnom Penh, Cambodia',
          suggestions: const [
            'Phnom Penh',
            'Siem Reap',
            'Sihanoukville',
            'Battambang',
            'Kampot',
          ],
          validators: [FormBuilderValidators.required()],
        ),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Employment Type'),
        const SizedBox(height: 8),
        FormDropdownInput(
          name: 'employmentType',
          hint: 'Select Type',
          icon: Icons.work_history_rounded,
          items: [
            'FullTime',
            'PartTime',
            'Contract',
            'Freelance',
            'Internship',
          ],
          validators: [FormBuilderValidators.required()],
        ),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Work Arrangement'),
        const SizedBox(height: 8),
        FormDropdownInput(
          name: 'workArrangement',
          hint: 'Select Arrangement',
          items: ['OnSite', 'Remote', 'Hybrid'],
          validators: [FormBuilderValidators.required()],
        ),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Experience Level'),
        const SizedBox(height: 8),
        FormDropdownInput(
          name: 'experienceLevel',
          hint: 'Select Level',
          items: ['Entry', 'Mid', 'Senior', 'Lead'],
          validators: [FormBuilderValidators.required()],
        ),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Positions Available'),
        const SizedBox(height: 8),
        FormTextInput(
          name: 'positionsAvailable',
          hint: 'e.g. 1',
          keyboardType: TextInputType.number,
          validators: [
            FormBuilderValidators.required(),
            FormBuilderValidators.numeric(),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
