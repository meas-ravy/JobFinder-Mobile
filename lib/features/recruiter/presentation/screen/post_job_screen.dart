import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/recruiter/presentation/provider/company/company_profile_controller.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/recruiter/presentation/screen/post_job_steps/job_details_step.dart';
import 'package:job_finder/features/recruiter/presentation/screen/post_job_steps/job_description_step.dart';
import 'package:job_finder/features/recruiter/presentation/screen/post_job_steps/requirements_step.dart';
import 'package:job_finder/features/recruiter/presentation/screen/post_job_steps/review_step.dart';
import 'package:job_finder/shared/widget/loading_dialog.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key, this.initialJobData});

  final Map<String, dynamic>? initialJobData;

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _currentStep = 1;
  late final bool _isEditing;
  late final Map<String, dynamic> _normalizedInitialData;

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 8),
            child: SizedBox(
              width: 100,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initialJobData != null;
    _normalizedInitialData = _normalizeData(widget.initialJobData);
  }

  Map<String, dynamic> _normalizeData(Map<String, dynamic>? data) {
    if (data == null) return {};
    final normalized = Map<String, dynamic>.from(data);

    // Normalize applicationDeadline
    if (normalized['applicationDeadline'] is String) {
      normalized['applicationDeadline'] = DateTime.tryParse(
        normalized['applicationDeadline'],
      );
    }

    // Normalize salary fields to String for FormBuilder compatibility
    if (normalized['salaryMin'] != null) {
      normalized['salaryMin'] = normalized['salaryMin'].toString();
    }
    if (normalized['salaryMax'] != null) {
      normalized['salaryMax'] = normalized['salaryMax'].toString();
    }

    // Normalize positionsAvailable to String
    if (normalized['positionsAvailable'] != null) {
      normalized['positionsAvailable'] = normalized['positionsAvailable']
          .toString();
    }

    return normalized;
  }

  Future<void> _submitJob() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = Map<String, dynamic>.from(_formKey.currentState!.value);

      // Parse numbers
      final minSalary = int.tryParse(values['salaryMin'].toString()) ?? 0;
      final maxSalary = int.tryParse(values['salaryMax'].toString()) ?? 0;
      final positionsAvailable =
          int.tryParse(values['positionsAvailable']?.toString() ?? '1') ?? 1;

      values['salaryMin'] = minSalary;
      values['salaryMax'] = maxSalary;
      values['positionsAvailable'] = positionsAvailable;

      // Handle Fixed salary type requirement for backend
      if (values['salaryType'] == 'Fixed') {
        values['salaryFixed'] = minSalary;
      }

      // Format date to ISO
      if (values['applicationDeadline'] is DateTime) {
        values['applicationDeadline'] =
            (values['applicationDeadline'] as DateTime).toIso8601String();
      }

      LoadingDialog.show(context, message: 'Posting job...');

      try {
        final controller = ref.read(recruiterJobsControllerProvider.notifier);

        if (_isEditing) {
          final jobId =
              widget.initialJobData!['_id'] ?? widget.initialJobData!['id'];
          await controller.updateJob(jobId, values);
        } else {
          await controller.createJob(values);
        }

        if (mounted) LoadingDialog.hide(context);

        final state = ref.read(recruiterJobsControllerProvider);
        if (state.errorMessage != null) {
          if (mounted) {
            _showErrorDialog('Post Failed', state.errorMessage!);
          }
        } else {
          if (mounted) {
            if (!_isEditing) {
              ref.read(recruiterHomeTabProvider.notifier).state = 1;
            }
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          LoadingDialog.hide(context);
          _showErrorDialog('Technical Error', e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final recruiterState = ref.watch(recruiterJobsControllerProvider);
    final companyState = ref.watch(companyProfileProvider);

    if (recruiterState.isLoading && companyState.company == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Job Post' : 'Add Job Post'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!recruiterState.isLoading && companyState.company == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Job Post' : 'Add Job Post'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.business_rounded,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Company Profile Required',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You need to set up your company profile before you can post a job.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
          _isEditing ? 'Edit Job Post' : 'Add Job Post',
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
              child: FormBuilder(
                key: _formKey,
                initialValue: _normalizedInitialData,
                child: _buildCurrentStep(),
              ),
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
                          if (_currentStep < 4) {
                            setState(() => _currentStep++);
                          } else {
                            _submitJob();
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
                        _currentStep < 4
                            ? 'Next'
                            : (_isEditing ? 'Update Job' : 'Post Job'),
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
        return const JobDetailsStep();
      case 2:
        return const JobDescriptionStep();
      case 3:
        return const RequirementsStep();
      case 4:
        return const ReviewStep();
      default:
        return const JobDetailsStep();
    }
  }

  Widget _buildStepIndicator(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(4 * 2 - 1, (index) {
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
