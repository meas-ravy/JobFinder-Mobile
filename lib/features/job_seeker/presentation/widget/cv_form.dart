import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CvForm extends StatelessWidget {
  const CvForm({
    super.key,
    this.initialValue,
    required this.name,
    required this.label,
    this.hint,
    this.validator,
    this.maxLines,
  });

  final String? initialValue;
  final String name, label;
  final String? hint;
  final String? Function(String?)? validator;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        hintStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.onSecondary.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.onSecondary.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.onSecondary.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      validator: validator,
      maxLines: maxLines,
    );
  }
}

class FormDateTime extends StatelessWidget {
  const FormDateTime({
    super.key,
    required this.name,
    required this.label,
    this.initialValue,
    this.hint,
    this.validator,
    this.maxLines,
  });

  final String name, label;
  final String? hint;
  final String? Function(DateTime?)? validator;
  final int? maxLines;
  final DateTime? initialValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FormBuilderDateTimePicker(
      name: name,
      initialValue: initialValue,
      inputType: InputType.date,
      validator: validator,
      decoration: InputDecoration(
        hintStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        hintText: hint,
        labelText: label,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.onSecondary.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.onSecondary.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.onSecondary.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
