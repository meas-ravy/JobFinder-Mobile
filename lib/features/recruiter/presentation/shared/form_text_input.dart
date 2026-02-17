import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class FormTextInput extends StatelessWidget {
  final String name;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLines;
  final List<String>? suggestions;
  final List<String? Function(String?)>? validators;

  const FormTextInput({
    super.key,
    required this.name,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.suggestions,
    this.validators,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderTextField(
          name: name,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validators != null
              ? FormBuilderValidators.compose(validators!)
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            filled: true,
            fillColor: colorScheme.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
          ),
        ),
        if (suggestions != null && suggestions!.isNotEmpty) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: suggestions!.map((suggestion) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      suggestion,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.05,
                    ),
                    side: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    onPressed: () {
                      FormBuilder.of(
                        context,
                      )!.fields[name]?.didChange(suggestion);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
