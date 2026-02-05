import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_finder/core/services/biometric_service.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/security_question_screen.dart';

class PinSetupScreen extends StatefulWidget {
  final bool isChanging;
  const PinSetupScreen({super.key, this.isChanging = false});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final BiometricService _biometricService = BiometricService();
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _errorMessage = '';

  void _onNumberPressed(String number) {
    setState(() {
      _errorMessage = '';
      if (!_isConfirming) {
        if (_pin.length < 4) {
          _pin += number;
        }
        if (_pin.length == 4) {
          _isConfirming = true;
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin += number;
        }
        if (_confirmPin.length == 4) {
          _verifyAndSave();
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirming = false;
          _pin = _pin.substring(0, _pin.length - 1);
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  Future<void> _verifyAndSave() async {
    if (_pin == _confirmPin) {
      await _biometricService.setAppPin(_pin);
      if (mounted) {
        // After PIN is set, go to Security Question setup
        final questionSet = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const SecurityQuestionScreen(),
          ),
        );

        if (mounted && questionSet == true) {
          Navigator.pop(context, true);
        }
      }
    } else {
      setState(() {
        _confirmPin = '';
        _errorMessage = 'PINs do not match. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: Text(widget.isChanging ? 'Change PIN' : 'Set PIN')),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              _isConfirming ? 'Confirm your PIN' : 'Enter a 4-digit PIN',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This PIN will be used to unlock your app locally.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(4, (index) {
                String currentPin = _isConfirming ? _confirmPin : _pin;
                bool isSelected = index < currentPin.length;
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
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(_errorMessage, style: TextStyle(color: colorScheme.error)),
            ],
            const Spacer(),
            _buildKeypad(colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          _buildRow(['1', '2', '3'], colorScheme, textTheme),
          _buildRow(['4', '5', '6'], colorScheme, textTheme),
          _buildRow(['7', '8', '9'], colorScheme, textTheme),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 80), // Empty space for layout
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
      onTap: () {
        HapticFeedback.lightImpact();
        _onNumberPressed(number);
      },
      borderRadius: BorderRadius.circular(40),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        width: 80,
        height: 80,
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
      onTap: () {
        HapticFeedback.lightImpact();
        _onBackspace();
      },
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        child: const Icon(Icons.backspace_outlined, size: 28),
      ),
    );
  }
}
