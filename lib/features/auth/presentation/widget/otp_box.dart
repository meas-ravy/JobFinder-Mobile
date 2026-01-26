import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpBox extends StatefulWidget {
  const OtpBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
    required this.isLast,
    required this.autofill,
    required this.index,
    required this.total,
    this.hasError = false,
    this.enableHaptics = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;
  final bool isLast;
  final bool autofill;
  final int index;
  final int total;
  final bool hasError;
  final bool enableHaptics;

  @override
  State<OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<OtpBox> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant OtpBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChange);
      widget.focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {});

    if (widget.focusNode.hasFocus && widget.controller.text.isNotEmpty) {
      widget.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.controller.text.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxDigits = widget.autofill ? 4 : 1;

    final isFocused = widget.focusNode.hasFocus;
    final borderColor = widget.hasError
        ? colorScheme.error
        : isFocused
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.12);
    final borderWidth = isFocused ? 1.6 : 1.0;

    return SizedBox(
      width: 60,
      height: 56,
      child: Semantics(
        label: 'OTP digit ${widget.index} of ${widget.total}',
        textField: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.18),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  widget.controller.text.isEmpty) {
                widget.onBackspace();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: widget.isLast
                  ? TextInputAction.done
                  : TextInputAction.next,
              maxLength: maxDigits,
              autofillHints: widget.autofill
                  ? const [AutofillHints.oneTimeCode]
                  : null,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(maxDigits),
              ],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              onTap: () {
                if (widget.controller.text.isNotEmpty) {
                  widget.controller.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: widget.controller.text.length,
                  );
                }
              },
              onChanged: (value) {
                if (widget.enableHaptics && value.isNotEmpty) {
                  HapticFeedback.selectionClick();
                }
                widget.onChanged(value);

                // dismiss keyboard when OTP is complete
                final shouldCloseKeyboard =
                    (widget.autofill && value.length >= 4) ||
                    (widget.isLast && value.isNotEmpty);
                if (shouldCloseKeyboard) {
                  FocusScope.of(context).unfocus();
                  TextInput.finishAutofillContext(shouldSave: true);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
