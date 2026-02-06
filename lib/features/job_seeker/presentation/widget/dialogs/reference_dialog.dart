import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/cv_form.dart';
import 'package:job_finder/l10n/app_localizations.dart';

class ReferenceDialog {
  static void show(
    BuildContext context, {
    Reference? existingRef,
    required Function(Reference) onSave,
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
                  existingRef != null ? l10n.editReference : l10n.addReference,
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
                        name: 'name',
                        label: l10n.fullNameLabel,
                        hint: l10n.referenceHint,
                        initialValue: existingRef?.name,
                        validator: FormBuilderValidators.required(),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'position',
                        label: l10n.positionLabel,
                        hint: l10n.positionHint,
                        initialValue: existingRef?.position,
                        validator: FormBuilderValidators.required(),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'company',
                        label: l10n.companyOptionalLabel,
                        hint: l10n.companyHint,
                        initialValue: existingRef?.company,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'email',
                        label: l10n.emailLabel,
                        hint: l10n.referenceEmailHint,
                        initialValue: existingRef?.email,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'phone',
                        label: l10n.phoneLabel,
                        hint: l10n.referencePhoneHint,
                        initialValue: existingRef?.phone,
                        validator: FormBuilderValidators.required(),
                        maxLines: 1,
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
                            final ref = Reference(
                              name: values['name'],
                              position: values['position'],
                              company: values['company'],
                              email: values['email'],
                              phone: values['phone'],
                            );
                            onSave(ref);
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          existingRef != null
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
