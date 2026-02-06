import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/cv_form.dart';
import 'package:job_finder/l10n/app_localizations.dart';

class ExperienceDialog {
  static void show(
    BuildContext context, {
    ExpEntity? existingExp,
    required Function(ExpEntity) onSave,
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
                  existingExp != null
                      ? l10n.editExperience
                      : l10n.addExperience,
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
                        label: l10n.jobTitleLabel,
                        hint: l10n.jobTitleHint,
                        initialValue: existingExp?.jobTitle,
                        validator: FormBuilderValidators.required(),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'companyName',
                        label: l10n.companyNameLabel,
                        hint: l10n.companyNameHint,
                        initialValue: existingExp?.companyName,
                        validator: FormBuilderValidators.required(),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'description',
                        label: l10n.jobDescriptionLabel,
                        hint: l10n.jobDescriptionHint,
                        initialValue: existingExp?.description,
                        validator: FormBuilderValidators.required(),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 12),
                      FormDateTime(
                        name: 'startDate',
                        label: l10n.startDateLabel,
                        initialValue: existingExp?.startDate,
                        hint: l10n.startDateHint,
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 12),
                      FormDateTime(
                        name: 'endDate',
                        label: l10n.endDateLabel,
                        hint: l10n.endDateHint,
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
                        child: Text(l10n.cancelButton),
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
                          existingExp != null
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
