import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/features/auth/presentation/widget/otp_box.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:job_finder/shared/components/primary_button.dart';

class VeriffyOtpScreen extends StatefulWidget {
  const VeriffyOtpScreen({super.key});

  @override
  State<VeriffyOtpScreen> createState() => _VeriffyOtpScreenState();
}

class _VeriffyOtpScreenState extends State<VeriffyOtpScreen> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(
      4,
      (index) => FocusNode(canRequestFocus: index == 0),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleChanged(int index, String value) {
    if (value.length > 1) {
      final lastChar = value[value.length - 1];
      if (_controllers[index].text != lastChar) {
        _controllers[index].text = lastChar;
        _controllers[index].selection = TextSelection.collapsed(
          offset: lastChar.length,
        );
      }
    }

    if (value.isNotEmpty && index < 4 - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }

    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  void _handleBackspace(int index) {
    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // _TopBar(onBack: () => Navigator.maybePop(context)),
            const SizedBox(height: 36),
            Column(
              children: [
                AppSvgIcon(
                  assetName: AppIcon.appLogoTwo,
                  size: 92,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 14),
                Text(
                  'Jober',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Verification Code',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We have sent the code to verification to\n+855******1234',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (index) => OtpBox(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (value) => _handleChanged(index, value),
                  onBackspace: () => _handleBackspace(index),
                  isLast: index == 4 - 1,
                  autofill: index == 0,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Resend code after ',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  '1:32',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            PrimaryButton(label: 'Verification', onPressed: () {}),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}