import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'shared_widgets.dart';

class CompanyInfoStep extends StatelessWidget {
  const CompanyInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company Information',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 24),
        const FormFieldLabel(label: 'Full Name'),
        const SizedBox(height: 8),
        const FormTextInput(name: 'full_name', hint: 'Enter name'),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Email'),
        const SizedBox(height: 8),
        FormTextInput(
          name: 'email',
          hint: 'Enter email address',
          keyboardType: TextInputType.emailAddress,
          validators: [FormBuilderValidators.email()],
        ),
        const SizedBox(height: 20),
        const FormFieldLabel(label: 'Location'),
        const SizedBox(height: 8),
        const FormTextInput(name: 'location', hint: 'Enter location'),
        const SizedBox(height: 24),
        const FormFieldLabel(label: 'Upload Image/Logo'),
        const SizedBox(height: 12),
        const FormUploadArea(),
        const SizedBox(height: 32),
      ],
    );
  }
}
