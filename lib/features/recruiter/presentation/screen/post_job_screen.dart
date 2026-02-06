import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'post_job_steps/company_info_step.dart';
import 'post_job_steps/job_details_step.dart';
import 'post_job_steps/job_description_step.dart';
import 'post_job_steps/requirements_step.dart';
import 'post_job_steps/review_step.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _currentStep = 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Add Job Post',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildStepIndicator(colorScheme, textTheme),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FormBuilder(key: _formKey, child: _buildCurrentStep()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentStep > 1) ...[
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _currentStep--);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Previous',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          if (_currentStep < 5) {
                            setState(() => _currentStep++);
                          } else {
                            // Submit form
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        _currentStep < 5 ? 'Next' : 'Post Job',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return const CompanyInfoStep();
      case 2:
        return const JobDetailsStep();
      case 3:
        return const JobDescriptionStep();
      case 4:
        return const RequirementsStep();
      case 5:
        return const ReviewStep();
      default:
        return const CompanyInfoStep();
    }
  }

  Widget _buildStepIndicator(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(5 * 2 - 1, (index) {
          if (index % 2 == 0) {
            final step = (index ~/ 2) + 1;
            final isActive = step == _currentStep;
            final isCompleted = step < _currentStep;

            return AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primary
                      : isCompleted
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive || isCompleted
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: textTheme.bodyLarge!.copyWith(
                      color: isActive
                          ? Colors.white
                          : isCompleted
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                    child: Text('$step'),
                  ),
                ),
              ),
            );
          } else {
            // Dotted line segment between circles
            final stepAfter = (index ~/ 2) + 2;
            final isCompletedLine = stepAfter <= _currentStep;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: DottedLine(
                  dashColor: isCompletedLine
                      ? colorScheme.primary
                      : colorScheme.outlineVariant.withValues(alpha: 0.5),
                  dashLength: 4,
                  dashGapLength: 3,
                  lineThickness: 1.5,
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}
