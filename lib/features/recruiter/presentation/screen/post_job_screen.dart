// Post Job Screen for recruiters
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/presentation/provider/company/company_profile_controller.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/recruiter/presentation/screen/post_job_steps/job_details_step.dart';
import 'package:job_finder/features/recruiter/presentation/screen/post_job_steps/job_description_step.dart';
import 'package:job_finder/features/recruiter/presentation/screen/post_job_steps/requirements_step.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:job_finder/features/recruiter/presentation/screen/post_job_steps/review_step.dart';
import 'package:job_finder/features/recruiter/presentation/widget/animation_ai_icon.dart';
import 'package:job_finder/shared/widget/loading_dialog.dart';
import 'package:job_finder/core/provider/gemini_service_provider.dart';
import 'package:job_finder/features/recruiter/data/models/job_model.dart';

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
  final DataMap _aggregateValues = {};
  bool _isAIGenerating = false;

  void _showErrorDialog(String title, String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.9),
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.black26,
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: Colors.red.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                  fontSize: 16,
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'I Understand',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generateWithAI({String? targetSection}) async {
    _formKey.currentState?.save();
    final title = _formKey.currentState?.value['title'] as String?;
    final category = _formKey.currentState?.value['category'] as String?;

    if (title == null || title.isEmpty || title.length < 5) {
      _showErrorDialog(
        'Missing Title',
        'Please enter Job Title first so AI can generate relevant content.',
      );
      return;
    }

    setState(() => _isAIGenerating = true);

    try {
      final gemini = ref.read(geminiServiceProvider);
      final content = await gemini.generateContent(
        title: title,
        category: category,
        experienceLevel:
            _formKey.currentState?.value['experienceLevel'] as String?,
      );

      if (content != null && mounted) {
        // Update form fields
        final DataMap patches = {};

        if (targetSection == null || targetSection == 'description') {
          patches['description'] = content['description'];
        }

        if (targetSection == null || targetSection == 'responsibilities') {
          patches['responsibilities'] = (content['responsibilities'] as List)
              .map((e) => '• $e')
              .join('\n');
        }

        if (targetSection == null || targetSection == 'requirements') {
          patches['requirements'] = (content['requirements'] as List)
              .map((e) => '• $e')
              .join('\n');
        }

        if (targetSection == null || targetSection == 'skills') {
          patches['skills'] = content['skills'];
        }

        _formKey.currentState?.patchValue(patches);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              targetSection == null
                  ? 'AI successfully generated job content!'
                  : 'AI updated the $targetSection!',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );

        // Auto move to next step ONLY if we generated everything and are at step 1
        if (_currentStep == 1 && targetSection == null) {
          setState(() => _currentStep = 2);
        }
      } else {
        if (mounted) {
          _showErrorDialog(
            'AI Error',
            'Failed to generate content. Please try again or check your API key.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('AI Error', e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isAIGenerating = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initialJobData != null;
    _aggregateValues.addAll(normalizeData(widget.initialJobData));
  }

  Future<void> _submitJob() async {
    _formKey.currentState?.save();
    _aggregateValues.addAll(_formKey.currentState!.value);

    LoadingDialog.show(context, message: 'Posting job...');

    try {
      final jobModel = JobModel.fromMap(_aggregateValues);
      final controller = ref.read(recruiterJobsControllerProvider.notifier);

      if (_isEditing) {
        final jobId = widget.initialJobData!['_id'] ?? widget.initialJobData!['id'];
        await controller.updateJob(jobId, jobModel);
      } else {
        await controller.createJob(jobModel);
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

    return Stack(
      children: [
        Scaffold(
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
                    initialValue: _aggregateValues,
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
                              side: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
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
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              _aggregateValues.addAll(_formKey.currentState!.value);
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
        ),
        if (_isAIGenerating) _buildAILoadingOverlay(colorScheme, textTheme),
      ],
    );
  }

  Widget _buildAILoadingOverlay(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AnimatedAIIcon(),
                      const SizedBox(height: 24),
                      Text(
                        'Jober is Writing...',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Drafting a professional Job post for you',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 140,
                        child: LinearProgressIndicator(
                          backgroundColor: colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return const JobDetailsStep();
      case 2:
        return JobDescriptionStep(
          onAIGenerate: _generateWithAI,
          onGenerateDescription: () =>
              _generateWithAI(targetSection: 'description'),
          onGenerateResponsibilities: () =>
              _generateWithAI(targetSection: 'responsibilities'),
          onGenerateRequirements: () =>
              _generateWithAI(targetSection: 'requirements'),
          onGenerateSkills: () => _generateWithAI(targetSection: 'skills'),
        );
      case 3:
        return const RequirementsStep();
      case 4:
        return ReviewStep(data: _aggregateValues);
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
