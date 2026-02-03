import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/data/model/template_model.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/cv_pdf_preview_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/build_expan_section.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/built_textfield.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/cv_photo_upload.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/dialogs/education_dialog.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/dialogs/experience_dialog.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/dialogs/reference_dialog.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/education_card.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/experience_card.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/reference_card.dart';

class CvFormScreen extends ConsumerStatefulWidget {
  final TempModel selectedTemplate;

  const CvFormScreen({super.key, required this.selectedTemplate});

  @override
  ConsumerState<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends ConsumerState<CvFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<ExpEntity> _experiences = [];
  final List<EduEntity> _educations = [];
  final List<Reference> _references = [];
  String _profileImagePath = '';

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
                          CvPhotoUpload(
                            onImagePicked: (path) {
                              _profileImagePath = path;
                            },
                          ),
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
                            (exp) => ExperienceCard(
                              exp: exp,
                              onEdit: () => ExperienceDialog.show(
                                context,
                                existingExp: exp,
                                onSave: (updatedExp) {
                                  setState(() {
                                    final index = _experiences.indexOf(exp);
                                    _experiences[index] = updatedExp;
                                  });
                                },
                              ),
                              onDelete: () {
                                setState(() {
                                  _experiences.remove(exp);
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => ExperienceDialog.show(
                              context,
                              onSave: (newExp) {
                                setState(() {
                                  _experiences.add(newExp);
                                });
                              },
                            ),
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
                          ..._educations.map(
                            (edu) => EducationCard(
                              edu: edu,
                              onEdit: () => EducationDialog.show(
                                context,
                                existingEdu: edu,
                                onSave: (updatedEdu) {
                                  setState(() {
                                    final index = _educations.indexOf(edu);
                                    _educations[index] = updatedEdu;
                                  });
                                },
                              ),
                              onDelete: () {
                                setState(() {
                                  _educations.remove(edu);
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => EducationDialog.show(
                              context,
                              onSave: (newEdu) {
                                setState(() {
                                  _educations.add(newEdu);
                                });
                              },
                            ),
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
                          ..._references.map(
                            (ref) => ReferenceCard(
                              ref: ref,
                              onEdit: () => ReferenceDialog.show(
                                context,
                                existingRef: ref,
                                onSave: (updatedRef) {
                                  setState(() {
                                    final index = _references.indexOf(ref);
                                    _references[index] = updatedRef;
                                  });
                                },
                              ),
                              onDelete: () {
                                setState(() {
                                  _references.remove(ref);
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => ReferenceDialog.show(
                              context,
                              onSave: (newRef) {
                                setState(() {
                                  _references.add(newRef);
                                });
                              },
                            ),
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
                onPressed: () => _previewCV(),
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

  /// Navigate to template preview with user's CV data
  void _previewCV() {
    if (_formKey.currentState!.saveAndValidate()) {
      final values = _formKey.currentState!.value;

      // Parse skills from comma-separated string
      final skillsString = (values['skills'] as String?) ?? '';
      final skills = skillsString
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      // Parse languages from comma-separated string
      final languagesString = (values['languages'] as String?) ?? '';
      final languages = languagesString
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      // Create CV entity with form data
      final cv = CvEntity(
        title: '${values['fullName']} - CV',
        imgurl: _profileImagePath,
        fullName: values['fullName'] ?? '',
        email: values['email'] ?? '',
        phone: values['phone'] ?? '',
        address: values['location'] ?? '',
        summary: values['Profile'],
        skills: skills,
        language: languages,
        updatedAt: DateTime.now(),
      );

      // Add experiences, educations, and references
      cv.exp.addAll(_experiences);
      cv.edu.addAll(_educations);
      cv.ref.addAll(_references);

      // Navigate to the selected template
      _navigateToTemplate(cv);
    }
  }

  /// Navigate to appropriate template based on selection
  void _navigateToTemplate(CvEntity cv) {
    // Navigate directly to PDF preview screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CvPdfPreviewScreen(
          cv: cv,
          templateName: widget.selectedTemplate.name,
        ),
      ),
    );
  }
}
