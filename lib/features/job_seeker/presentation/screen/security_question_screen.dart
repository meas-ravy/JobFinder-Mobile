import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_finder/core/services/biometric_service.dart';

class SecurityQuestionScreen extends StatefulWidget {
  const SecurityQuestionScreen({super.key});

  @override
  State<SecurityQuestionScreen> createState() => _SecurityQuestionScreenState();
}

class _SecurityQuestionScreenState extends State<SecurityQuestionScreen> {
  final BiometricService _biometricService = BiometricService();
  final List<String> _questions = [
    'What is the name of your first pet?',
    'What city or town were you born in?',
    'What was the name of your favorite childhood friend?',
    'What is your favorite color?',
    'What is the name of your elementary school?',
    'What city or town did your parents meet in?',
    'What is the name of your first teacher?',
  ];

  String? _selectedQuestion;
  final TextEditingController _answerController = TextEditingController();
  bool _isDone = false;

  void _onQuestionSelected(String question) {
    setState(() {
      _selectedQuestion = question;
      // Clear answer when picking a new question
      _answerController.clear();
      _isDone = false;
    });
    _showAnswerDialog(question);
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _showAnswerDialog(String question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _answerController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter your answer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _answerController.text.trim().isEmpty
                      ? null
                      : () {
                          setState(() {
                            _isDone = true;
                          });
                          Navigator.pop(context);
                        },
                  child: Text(
                    'Confirm Answer',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAndFinish() async {
    if (_selectedQuestion != null && _answerController.text.isNotEmpty) {
      await _biometricService.saveSecurityData(
        _selectedQuestion!,
        _answerController.text,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
              final isSelected = _selectedQuestion == question && _isDone;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 4,
                ),
                leading: isSelected
                    ? Icon(Icons.check_circle, color: colorScheme.primary)
                    : null,
                title: Text(
                  question,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.54),
                ),
                onTap: () => _onQuestionSelected(question),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: GestureDetector(
                onTap: _isDone ? _saveAndFinish : null,
                child: Opacity(
                  opacity: _isDone ? 1.0 : 0.5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.save,
                          color: colorScheme.onSurface,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Done',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
