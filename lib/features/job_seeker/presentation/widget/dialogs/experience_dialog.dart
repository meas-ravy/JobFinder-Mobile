import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/cv_form.dart';

class ExperienceDialog {
  static void show(
    BuildContext context, {
    ExpEntity? existingExp,
    required Function(ExpEntity) onSave,
  }) {
    final formKey = GlobalKey<FormBuilderState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existingExp != null ? 'Edit Experience' : 'Add Experience',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                FormBuilder(
                  key: formKey,
                  child: Column(
                    children: [
                      CvForm(
                        name: 'jobTitle',
                        label: 'Job Title',
                        hint: 'Software Engineer',
                        initialValue: existingExp?.jobTitle,
                        validator: FormBuilderValidators.required(),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'companyName',
                        label: 'Company Name',
                        hint: 'Google',
                        initialValue: existingExp?.companyName,
                        validator: FormBuilderValidators.required(),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'description',
                        label: 'Job Description',
                        hint:
                            'Type each point on a new line.\n'
                            'e.g.\n'
                            'Developed mobile apps\n'
                            'Fixed critical bugs',
                        initialValue: existingExp?.description,
                        validator: FormBuilderValidators.required(),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 12),
                      FormDateTime(
                        name: 'startDate',
                        label: 'Start Date',
                        initialValue: existingExp?.startDate,
                        hint: '2024',
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 12),
                      FormDateTime(
                        name: 'endDate',
                        label: 'End Date',
                        hint: '2026',
                        initialValue: existingExp?.endDate,
                        validator: FormBuilderValidators.required(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.saveAndValidate()) {
                            final values = formKey.currentState!.value;
                            final exp = ExpEntity(
                              jobTitle: values['jobTitle'],
                              companyName: values['companyName'],
                              description: values['description'],
                              startDate: values['startDate'],
                              endDate: values['endDate'],
                            );
                            onSave(exp);
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          existingExp != null ? 'Update' : 'Add',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
