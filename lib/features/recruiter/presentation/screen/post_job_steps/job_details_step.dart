import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:job_finder/features/recruiter/presentation/shared/form_dropdown_input.dart';
import 'package:job_finder/features/recruiter/presentation/shared/form_field_label.dart';
import 'package:job_finder/features/recruiter/presentation/shared/form_text_input.dart';

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
          items: const [
            'Technology',
            'Healthcare',
            'Finance',
            'Education',
            'Marketing',
            'Sales',
            'Engineering',
            'Design',
            'CustomerService',
            'HumanResources',
            'Operations',
            'Legal',
            'Construction',
            'Retail',
            'Hospitality',
            'Manufacturing',
            'Transportation',
            'RealEstate',
            'Media',
            'Other',
          ],
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
            'Phnom Penh, Cambodia',
            'Siem Reap, Cambodia',
            'Sihanoukville, Cambodia',
            'Battambang, Cambodia',
            'Kampot, Cambodia',
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
          items: ['Entry', 'Mid', 'Senior', 'Lead', 'Executive'],
          validators: [FormBuilderValidators.required()],
        ),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Positions Available'),
        const SizedBox(height: 8),
        FormTextInput(
          name: 'positionsAvailable',
          hint: 'Enter number of positions available',
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
