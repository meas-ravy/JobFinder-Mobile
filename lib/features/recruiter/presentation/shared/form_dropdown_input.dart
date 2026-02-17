import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class FormDropdownInput extends StatelessWidget {
  final String name;
  final String hint;
  final List<String> items;
  final IconData? icon;
  final List<String? Function(dynamic)>? validators;

  const FormDropdownInput({
    super.key,
    required this.name,
    required this.hint,
    required this.items,
    this.icon,
    this.validators,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FormBuilderDropdown<String>(
      name: name,
      validator: validators != null
          ? FormBuilderValidators.compose(validators!)
          : null,
      icon: Icon(
        Icons.expand_more_rounded,
        color: colorScheme.primary,
        size: 24,
      ),
      elevation: 8,
      dropdownColor: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      menuMaxHeight: 400,
      selectedItemBuilder: (BuildContext context) {
        return items.map<Widget>((String item) {
          return Text(
            item,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          );
        }).toList();
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 48),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
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
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon ?? Icons.location_on_rounded,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.contains(',') ? item.split(',').first : item,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (item.contains(','))
                            Text(
                              item.split(',').last.trim(),
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
