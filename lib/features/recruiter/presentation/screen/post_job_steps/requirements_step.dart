import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:job_finder/features/recruiter/presentation/shared/form_date_picker.dart';
import 'package:job_finder/features/recruiter/presentation/shared/form_dropdown_input.dart';
import 'package:job_finder/features/recruiter/presentation/shared/form_field_label.dart';
import 'package:job_finder/features/recruiter/presentation/shared/form_list_input.dart';
import 'package:job_finder/features/recruiter/presentation/shared/form_text_input.dart';

class RequirementsStep extends StatelessWidget {
  const RequirementsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compensation & Benefits',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 24),
        const FormFieldLabel(label: 'Salary Type'),
        const SizedBox(height: 8),
        FormDropdownInput(
          name: 'salaryType',
          hint: 'Select Salary Type',
          items: const ['Range', 'Fixed', 'Negotiable'],
          validators: [FormBuilderValidators.required()],
        ),
        const SizedBox(height: 20),
        Consumer(
          builder: (context, ref, child) {
            final salaryType = FormBuilder.of(
              context,
            )?.fields['salaryType']?.value;
            final isFixed = salaryType == 'Fixed';
            final isRange = salaryType == 'Range';

            if (!isFixed && !isRange) return const SizedBox.shrink();

            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormFieldLabel(
                        label: isFixed ? 'Salary Amount' : 'Min Salary',
                      ),
                      const SizedBox(height: 8),
                      FormTextInput(
                        name: 'salaryMin',
                        hint: 'e.g. 1000',
                        keyboardType: TextInputType.number,
                        validators: [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric(),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isRange) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FormFieldLabel(label: 'Max Salary'),
                        const SizedBox(height: 8),
                        FormTextInput(
                          name: 'salaryMax',
                          hint: 'e.g. 2000',
                          keyboardType: TextInputType.number,
                          validators: [
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FormFieldLabel(label: 'Currency'),
                  const SizedBox(height: 8),
                  FormDropdownInput(
                    name: 'salaryCurrency',
                    hint: 'Select',
                    items: const ['USD', 'KHR'],
                    validators: [FormBuilderValidators.required()],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FormFieldLabel(label: 'Period'),
                  const SizedBox(height: 8),
                  FormDropdownInput(
                    name: 'salaryPeriod',
                    hint: 'Select',
                    items: const ['Month', 'Year', 'Week', 'Day', 'Hour'],
                    validators: [FormBuilderValidators.required()],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FormListInput(
          name: 'benefits',
          hint: 'Type a benefit and press enter...',
          label: 'Benefits',
          suggestions: const [
            'Health insurance',
            'Flexible working hours',
            'Remote / hybrid work option',
            'Annual performance bonus',
            'Paid annual leave',
            'Professional training & certifications',
            'Career growth opportunities',
            'Travel or transport allowance',
          ],
          validators: [FormBuilderValidators.required()],
        ),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Application Deadline'),
        const SizedBox(height: 8),
        FormDatePicker(
          name: 'applicationDeadline',
          hint: 'Select Deadline',
          validators: [
            FormBuilderValidators.required(),
            (value) {
              if (value != null && value.isBefore(DateTime.now())) {
                return 'Deadline cannot be in the past';
              }
              return null;
            },
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
