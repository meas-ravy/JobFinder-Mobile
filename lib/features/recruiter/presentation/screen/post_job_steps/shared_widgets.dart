import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class FormFieldLabel extends StatelessWidget {
  final String label;

  const FormFieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      label,
      style: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
  }
}

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

class FormDatePicker extends StatelessWidget {
  final String name;
  final String hint;
  final List<String? Function(DateTime?)>? validators;

  const FormDatePicker({
    super.key,
    required this.name,
    required this.hint,
    this.validators,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FormBuilderDateTimePicker(
      name: name,
      inputType: InputType.date,
      validator: validators != null
          ? FormBuilderValidators.compose(validators!)
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        suffixIcon: Icon(
          Icons.calendar_today_rounded,
          color: colorScheme.primary,
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
    );
  }
}

class FormUploadArea extends StatelessWidget {
  const FormUploadArea({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, 160),
            painter: DashedRectPainter(
              color: colorScheme.primary.withValues(alpha: 0.3),
              strokeWidth: 1,
              gap: 4,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.file_upload_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Upload File',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    children: [
                      const TextSpan(text: 'Supported: '),
                      TextSpan(
                        text: '(png)  (Jpg)  (Svg)  (20mb)',
                        style: TextStyle(
                          color: colorScheme.primary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(20),
        ),
      );

    final dashPath = buildDashPath(path, gap);
    canvas.drawPath(dashPath, paint);
  }

  Path buildDashPath(Path source, double gap) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dest.addPath(metric.extractPath(distance, distance + gap), Offset.zero);
        distance += gap * 2;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
