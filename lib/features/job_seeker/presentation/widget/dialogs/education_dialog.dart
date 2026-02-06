import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/cv_form.dart';
import 'package:job_finder/l10n/app_localizations.dart';

class EducationDialog {
  static void show(
    BuildContext context, {
    EduEntity? existingEdu,
    required Function(EduEntity) onSave,
  }) {
    final formKey = GlobalKey<FormBuilderState>();
    final l10n = AppLocalizations.of(context);

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
                  existingEdu != null ? l10n.editEducation : l10n.addEducation,
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
                        name: 'degree',
                        label: l10n.degreeLabel,
                        hint: l10n.degreeHint,
                        initialValue: existingEdu?.degree,
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'institute',
                        label: l10n.institutionLabel,
                        hint: l10n.institutionHint,
                        initialValue: existingEdu?.institution,
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 12),
                      FormDateTime(
                        name: 'startDate',
                        label: l10n.startDateLabel,
                        hint: l10n.startDateHint,
                        initialValue: existingEdu?.startDate,
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 12),
                      FormDateTime(
                        name: 'endDate',
                        label: l10n.endDateLabel,
                        hint: l10n.endDateHint,
                        initialValue: existingEdu?.endDate,
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
                        child: Text(l10n.cancelButton),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.saveAndValidate()) {
                            final values = formKey.currentState!.value;
                            final edu = EduEntity(
                              degree: values['degree'],
                              institution: values['institute'],
                              startDate: values['startDate'],
                              endDate: values['endDate'],
                            );
                            onSave(edu);
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          existingEdu != null
                              ? l10n.updateButton
                              : l10n.addButton,
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
