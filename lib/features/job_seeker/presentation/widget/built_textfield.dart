import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class BuiltTextfield extends StatelessWidget {
  const BuiltTextfield({
    super.key,
    required this.name,
    required this.label,
    this.maxLine = 1,
    this.validator,
    this.hint,
  });

  final String name, label;
  final int maxLine;
  final FormFieldValidator<String>? validator;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        labelStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 12,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.onSecondary.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.onSecondary.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      maxLines: maxLine,
      validator: validator,
    );
  }
}
