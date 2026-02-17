import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:job_finder/features/recruiter/presentation/shared/form_field_label.dart';

class FormListInput extends StatefulWidget {
  final String name;
  final String hint;
  final String label;
  final List<String>? suggestions;
  final List<String? Function(String?)>? validators;

  const FormListInput({
    super.key,
    required this.name,
    required this.hint,
    required this.label,
    this.suggestions,
    this.validators,
  });

  @override
  State<FormListInput> createState() => _FormListInputState();
}

class _FormListInputState extends State<FormListInput> {
  final TextEditingController _textController = TextEditingController();

  void _addItem(FormFieldState<String?> field, String value) {
    if (value.trim().isEmpty) return;

    final currentText = field.value ?? '';
    final items = currentText
        .split('\n')
        .where((e) => e.trim().startsWith('• '))
        .map((e) => e.replaceFirst('• ', '').trim())
        .toList();

    if (!items.contains(value.trim())) {
      items.add(value.trim());
      final newText = items.map((e) => '• $e').join('\n');
      field.didChange(newText);
      _textController.clear();
    }
  }

  void _removeItem(FormFieldState<String?> field, String itemToRemove) {
    final currentText = field.value ?? '';
    final items = currentText
        .split('\n')
        .where((e) => e.trim().startsWith('• '))
        .map((e) => e.replaceFirst('• ', '').trim())
        .toList();

    items.remove(itemToRemove.trim());
    final newText = items.isEmpty ? null : items.map((e) => '• $e').join('\n');
    field.didChange(newText);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FormBuilderField<String>(
      name: widget.name,
      validator: widget.validators != null
          ? FormBuilderValidators.compose(widget.validators!)
          : null,
      builder: (FormFieldState<String?> field) {
        final currentText = field.value ?? '';
        final items = currentText
            .split('\n')
            .where((e) => e.trim().startsWith('• '))
            .map((e) => e.replaceFirst('• ', '').trim())
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormFieldLabel(label: widget.label),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              onSubmitted: (value) => _addItem(field, value),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                filled: true,
                fillColor: colorScheme.surface,
                suffixIcon: IconButton(
                  icon: Icon(Icons.add_circle, color: colorScheme.primary),
                  onPressed: () => _addItem(field, _textController.text),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            if (widget.suggestions != null &&
                widget.suggestions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.suggestions!.map((suggestion) {
                    final isAdded = items.contains(suggestion);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(
                          suggestion,
                          style: textTheme.labelSmall?.copyWith(
                            color: isAdded
                                ? colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.5,
                                  )
                                : colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: isAdded
                            ? colorScheme.outlineVariant.withValues(alpha: 0.1)
                            : colorScheme.primary.withValues(alpha: 0.05),
                        side: BorderSide(
                          color: isAdded
                              ? colorScheme.outlineVariant.withValues(
                                  alpha: 0.2,
                                )
                              : colorScheme.primary.withValues(alpha: 0.1),
                        ),
                        onPressed: isAdded
                            ? null
                            : () => _addItem(field, suggestion),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  field.errorText ?? '',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 4,
                    top: 4,
                    bottom: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          item,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        onPressed: () => _removeItem(field, item),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
