import 'package:flutter/material.dart';

class AppLockKeypadView extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String pin;
  final String errorMessage;
  final bool isBiometricAvailable;
  final bool canPop;
  final Function(String) onNumberPressed;
  final VoidCallback onBackspace;
  final VoidCallback onBiometricPressed;
  final VoidCallback onBack;

  const AppLockKeypadView({
    super.key,
    this.title,
    this.subtitle,
    required this.pin,
    required this.errorMessage,
    required this.isBiometricAvailable,
    required this.canPop,
    required this.onNumberPressed,
    required this.onBackspace,
    required this.onBiometricPressed,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          const Spacer(),
          const Icon(Icons.lock_person_outlined, size: 64),
          const SizedBox(height: 24),
          Text(
            title ?? 'App Locked',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle ?? 'Enter your PIN to continue',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (index) {
              bool isSelected = index < pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.1),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              );
            }),
          ),
          if (errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(errorMessage, style: TextStyle(color: colorScheme.error)),
          ],
          const SizedBox(height: 20),
          _buildKeypad(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildKeypad(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 50),
      child: Column(
        children: [
          _buildRow(['1', '2', '3'], colorScheme, textTheme),
          _buildRow(['4', '5', '6'], colorScheme, textTheme),
          _buildRow(['7', '8', '9'], colorScheme, textTheme),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBiometricButton(colorScheme),
              _buildNumberButton('0', colorScheme, textTheme),
              _buildBackspaceButton(colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    List<String> numbers,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: numbers
            .map((n) => _buildNumberButton(n, colorScheme, textTheme))
            .toList(),
      ),
    );
  }

  Widget _buildNumberButton(
    String number,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return InkWell(
      onTap: () => onNumberPressed(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(ColorScheme colorScheme) {
    return InkWell(
      onTap: onBackspace,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        child: const Icon(Icons.backspace_outlined, size: 28),
      ),
    );
  }

  Widget _buildBiometricButton(ColorScheme colorScheme) {
    if (!isBiometricAvailable) return const SizedBox(width: 80);
    return InkWell(
      onTap: onBiometricPressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        child: Icon(Icons.fingerprint, size: 32, color: colorScheme.primary),
      ),
    );
  }
}
