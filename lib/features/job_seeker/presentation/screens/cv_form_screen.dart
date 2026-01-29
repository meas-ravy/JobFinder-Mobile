import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/build_expan_section.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/built_textfield.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/cv_form.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/cv_photo_upload.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class CvFormScreen extends ConsumerStatefulWidget {
  const CvFormScreen({super.key});

  @override
  ConsumerState<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends ConsumerState<CvFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<ExpEntity> _experiences = [];
  final List<EduEntity> _educations = [];
  final List<Reference> _references = [];

  // Expansion states
  bool _isPersonalDataExpanded = false;
  bool _isSummaryExpanded = false;
  bool _isExperienceExpanded = false;
  bool _isEducationExpanded = false;
  bool _isSkillsExpanded = false;
  bool _isLanguagesExpanded = false;
  bool _isReferencesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Fill your data',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Data Section
                    BuildExpanSection(
                      title: 'Personal Data',
                      desc:
                          'Complete your personal data to make your resume even better',
                      isExpanded: _isPersonalDataExpanded,
                      onToggle: () {
                        setState(() {
                          _isPersonalDataExpanded = !_isPersonalDataExpanded;
                        });
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // Profile Photo Upload
                          CvPhotoUpload(),
                          const SizedBox(height: 24),
                          BuiltTextfield(
                            name: 'fullName',
                            label: 'Full Name',
                            hint: 'Jake sonner',
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: 16),
                          BuiltTextfield(
                            name: 'email',
                            label: 'Email',
                            hint: 'jakesonner@gmail.com',
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.email(),
                            ]),
                          ),
                          const SizedBox(height: 16),
                          BuiltTextfield(
                            name: 'location',
                            label: 'Location',
                            hint: 'Toul Kork, Boeung Keng Kang, Phnom Penh',
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: 16),
                          BuiltTextfield(
                            name: 'phone',
                            label: 'Phone',
                            hint: '0964516334',
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: 16),
                          // Date of Birth
                          Text(
                            'Date of Birth',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: BuiltTextfield(
                                  name: 'dobDay',
                                  label: 'Day',
                                  hint: '24',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: BuiltTextfield(
                                  name: 'dobMonth',
                                  label: 'Month',
                                  hint: '05',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: BuiltTextfield(
                                  name: 'dobYear',
                                  label: 'Year',
                                  hint: '1999',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Divider(
                      thickness: 1.3,
                      color: colorScheme.onSecondary.withValues(alpha: 0.3),
                    ),

                    // Summary Section
                    BuildExpanSection(
                      title: 'Profile',
                      desc: 'Explain summary of your Profile background',
                      isExpanded: _isSummaryExpanded,
                      onToggle: () {
                        setState(() {
                          _isSummaryExpanded = !_isSummaryExpanded;
                        });
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          BuiltTextfield(
                            name: 'Profile',
                            label: 'Personal Profile',
                            hint: 'Write your Personal Profile summary here...',
                            maxLine: 5,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Divider(
                      thickness: 1.3,
                      color: colorScheme.onSecondary.withValues(alpha: 0.3),
                    ),

                    // Experience Section
                    BuildExpanSection(
                      title: 'Experience',
                      desc:
                          'Enter details about what you did in your previous jobs, start with your most recent responsibilities',
                      isExpanded: _isExperienceExpanded,
                      onToggle: () {
                        setState(() {
                          _isExperienceExpanded = !_isExperienceExpanded;
                        });
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          ..._experiences.map(
                            (exp) => _buildExperienceCard(exp),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _showAddExperienceDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Experience'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(55),
                              side: BorderSide(color: colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Divider(
                      thickness: 1.3,
                      color: colorScheme.onSecondary.withValues(alpha: 0.3),
                    ),

                    // Education Section
                    BuildExpanSection(
                      title: 'Education',
                      desc:
                          'List your educational background, starting from the most recent',
                      isExpanded: _isEducationExpanded,
                      onToggle: () {
                        setState(() {
                          _isEducationExpanded = !_isEducationExpanded;
                        });
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          ..._educations.map((edu) => _buildEducationCard(edu)),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _showAddEducationDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Education'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              side: BorderSide(color: colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Divider(
                      thickness: 1.3,
                      color: colorScheme.onSecondary.withValues(alpha: 0.3),
                    ),

                    BuildExpanSection(
                      title: 'References',
                      desc: 'List your references',
                      isExpanded: _isReferencesExpanded,
                      onToggle: () {
                        setState(() {
                          _isReferencesExpanded = !_isReferencesExpanded;
                        });
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          ..._references.map((ref) => _buildReferenceCard(ref)),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _showAddReferenceDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Reference'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              side: BorderSide(color: colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Divider(
                      thickness: 1.3,
                      color: colorScheme.onSecondary.withValues(alpha: 0.3),
                    ),

                    BuildExpanSection(
                      title: 'Languages',
                      desc: 'Add your key languages',
                      isExpanded: _isLanguagesExpanded,
                      onToggle: () {
                        setState(() {
                          _isLanguagesExpanded = !_isLanguagesExpanded;
                        });
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          BuiltTextfield(
                            name: 'languages',
                            label: 'Languages',
                            hint:
                                'e.g., khmer, english, chinese (comma separated)',
                            maxLine: 3,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Divider(
                      thickness: 1.3,
                      color: colorScheme.onSecondary.withValues(alpha: 0.3),
                    ),
                    // Skills Section
                    BuildExpanSection(
                      title: 'Skills',
                      desc: 'Add your key skills and competencies',
                      isExpanded: _isSkillsExpanded,
                      onToggle: () {
                        setState(() {
                          _isSkillsExpanded = !_isSkillsExpanded;
                        });
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          BuiltTextfield(
                            name: 'skills',
                            label: 'Skills',
                            hint:
                                'e.g., Flutter, Dart, UI/UX (comma separated)',
                            maxLine: 3,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // Preview & Export Button (Fixed at bottom)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Preview & Export',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(ExpEntity exp) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.onSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exp.jobTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: AppSvgIcon(
                  assetName: AppIcon.edit,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
                onPressed: () {
                  _showAddExperienceDialog(existingExp: exp);
                },
              ),
              IconButton(
                icon: const AppSvgIcon(
                  assetName: AppIcon.delete,
                  size: 20,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    _experiences.remove(exp);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            exp.companyName,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${exp.startDate.year} - ${exp.endDate.year}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCard(EduEntity edu) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  edu.degree,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: AppSvgIcon(
                  assetName: AppIcon.edit,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
                onPressed: () {
                  _showAddEducationDialog(existingEdu: edu);
                },
              ),
              IconButton(
                icon: const AppSvgIcon(
                  assetName: AppIcon.delete,
                  size: 20,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    _educations.remove(edu);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            edu.institution,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${edu.startDate.year} - ${edu.endDate.year}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExperienceDialog({ExpEntity? existingExp}) {
    final formKey = GlobalKey<FormBuilderState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existingExp != null ? 'Edit Experience' : 'Add Experience',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                FormBuilder(
                  key: formKey,
                  child: Column(
                    children: [
                      CvForm(
                        name: 'jobTitle',
                        label: 'Job Title',
                        hint: 'Software Engineer',
                        validator: FormBuilderValidators.required(),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'companyName',
                        label: 'Company Name',
                        hint: 'Google',
                        validator: FormBuilderValidators.required(),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'description',
                        label: 'Description',
                        hint:
                            '• Manage marketing budgets\n'
                            '• Conduct market research\n'
                            '• Ensure brand consistency across channels',
                        validator: FormBuilderValidators.required(),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      FormDateTime(
                        name: 'startDate',
                        label: 'Start Date',
                        initialValue: existingExp?.startDate,
                        hint: '2024',
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 12),
                      FormDateTime(
                        name: 'endDate',
                        label: 'End Date',
                        hint: '2026',
                        initialValue: existingExp?.endDate,
                        validator: FormBuilderValidators.required(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.saveAndValidate()) {
                            final values = formKey.currentState!.value;
                            setState(() {
                              if (existingExp != null) {
                                // Edit existing
                                final index = _experiences.indexOf(existingExp);
                                _experiences[index] = ExpEntity(
                                  jobTitle: values['jobTitle'],
                                  companyName: values['companyName'],
                                  description: values['description'],
                                  startDate: values['startDate'],
                                  endDate: values['endDate'],
                                );
                              } else {
                                // Add new
                                _experiences.add(
                                  ExpEntity(
                                    jobTitle: values['jobTitle'],
                                    companyName: values['companyName'],
                                    description: values['description'],
                                    startDate: values['startDate'],
                                    endDate: values['endDate'],
                                  ),
                                );
                              }
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          existingExp != null ? 'Update' : 'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEducationDialog({EduEntity? existingEdu}) {
    final formKey = GlobalKey<FormBuilderState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existingEdu != null ? 'Edit Education' : 'Add Education',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                FormBuilder(
                  key: formKey,
                  child: Column(
                    children: [
                      CvForm(
                        name: 'degree',
                        label: 'Degree',
                        hint: 'Bachelor of Computer Science',
                        initialValue: existingEdu?.degree,
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'institute',
                        label: 'Institution',
                        hint: 'Royal University of Phnom Penh',
                        initialValue: existingEdu?.institution,
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 12),
                      FormDateTime(
                        name: 'startDate',
                        label: 'Start Date',
                        hint: '2022',
                        initialValue: existingEdu?.startDate,
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 12),
                      FormDateTime(
                        name: 'endDate',
                        label: 'End Date',
                        hint: '2026',
                        initialValue: existingEdu?.endDate,
                        validator: FormBuilderValidators.required(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.saveAndValidate()) {
                            final values = formKey.currentState!.value;
                            setState(() {
                              if (existingEdu != null) {
                                // Edit existing
                                final index = _educations.indexOf(existingEdu);
                                _educations[index] = EduEntity(
                                  degree: values['degree'],
                                  institution: values['institution'],
                                  startDate: values['startDate'],
                                  endDate: values['endDate'],
                                );
                              } else {
                                // Add new
                                _educations.add(
                                  EduEntity(
                                    degree: values['degree'],
                                    institution: values['institution'],
                                    startDate: values['startDate'],
                                    endDate: values['endDate'],
                                  ),
                                );
                              }
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          existingEdu != null ? 'Update' : 'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferenceCard(Reference ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSecondary.withValues(alpha: .3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ref.name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: AppSvgIcon(
                  assetName: AppIcon.edit,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
                onPressed: () {
                  _showAddReferenceDialog(existingRef: ref);
                },
              ),
              IconButton(
                icon: const AppSvgIcon(
                  assetName: AppIcon.delete,
                  size: 20,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    _references.remove(ref);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${ref.position}${ref.company != null ? ' at ${ref.company}' : ''}',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ref.email,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ref.phone,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReferenceDialog({Reference? existingRef}) {
    final formKey = GlobalKey<FormBuilderState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existingRef != null ? 'Edit Reference' : 'Add Reference',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                FormBuilder(
                  key: formKey,
                  child: Column(
                    children: [
                      CvForm(
                        name: 'name',
                        label: 'Full Name',
                        hint: 'Alex Johnson',
                        initialValue: existingRef?.name,
                        validator: FormBuilderValidators.required(),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'position',
                        label: 'Position',
                        hint: 'Senior Manager',
                        initialValue: existingRef?.position,
                        validator: FormBuilderValidators.required(),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'company',
                        label: 'Company (Optional)',
                        hint: 'ABC Corporation',
                        initialValue: existingRef?.company,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'email',
                        label: 'Email',
                        hint: 'alex.johnson@example.com',
                        initialValue: existingRef?.email,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      CvForm(
                        name: 'phone',
                        label: 'Phone',
                        hint: '+1 234 567 8900',
                        initialValue: existingRef?.phone,
                        validator: FormBuilderValidators.required(),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.saveAndValidate()) {
                            final values = formKey.currentState!.value;
                            setState(() {
                              if (existingRef != null) {
                                // Edit existing
                                final index = _references.indexOf(existingRef);
                                _references[index] = Reference(
                                  name: values['name'],
                                  position: values['position'],
                                  company: values['company'],
                                  email: values['email'],
                                  phone: values['phone'],
                                );
                              } else {
                                // Add new
                                _references.add(
                                  Reference(
                                    name: values['name'],
                                    position: values['position'],
                                    company: values['company'],
                                    email: values['email'],
                                    phone: values['phone'],
                                  ),
                                );
                              }
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          existingRef != null ? 'Update' : 'Add',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
