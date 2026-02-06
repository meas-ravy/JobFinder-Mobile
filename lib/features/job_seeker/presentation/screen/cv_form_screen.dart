import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/data/model/template_model.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/cv_pdf_preview_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/built_textfield.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/cv_photo_upload.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/dialogs/education_dialog.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/dialogs/experience_dialog.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/dialogs/reference_dialog.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/education_card.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/experience_card.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/reference_card.dart';
import 'package:job_finder/features/job_seeker/presentation/providers/cv_provider.dart';
import 'package:job_finder/shared/components/primary_button.dart';
import 'package:job_finder/l10n/app_localizations.dart';

class CvFormScreen extends ConsumerStatefulWidget {
  final TempModel selectedTemplate;
  final CvEntity? initialCv;

  const CvFormScreen({
    super.key,
    required this.selectedTemplate,
    this.initialCv,
  });

  @override
  ConsumerState<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends ConsumerState<CvFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  final List<ExpEntity> _experiences = [];
  final List<EduEntity> _educations = [];
  final List<Reference> _references = [];
  String _profileImagePath = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialCv != null) {
      final cv = widget.initialCv!;
      _experiences.addAll(cv.exp);
      _educations.addAll(cv.edu);
      _references.addAll(cv.ref);
      _profileImagePath = cv.imgurl;

      // Populate form fields after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.patchValue({
          'fullName': cv.fullName,
          'email': cv.email,
          'location': cv.address,
          'phone': cv.phone,
          'Profile': cv.summary,
          'skills': cv.skills.join(', '),
          'languages': cv.language.join(', '),
        });
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _previewCV();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.createCvTitle,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: List.generate(
                _totalPages,
                (index) => Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      height: 10,
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildPersonalPage(context),
                  _buildExperiencePage(context),
                  _buildEducationPage(context),
                  _buildSkillsLanguagesPage(context),
                  _buildReferencesPage(context),
                ],
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalPage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.personalInfo,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.reachRecruiters,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.center,
            child: CvPhotoUpload(
              initialImage: _profileImagePath,
              onImagePicked: (path) {
                _profileImagePath = path;
              },
            ),
          ),
          const SizedBox(height: 24),
          BuiltTextfield(
            name: 'fullName',
            label: l10n.fullNameLabel,
            hint: l10n.fullNameHint,
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 16),
          BuiltTextfield(
            name: 'email',
            label: l10n.emailLabel,
            hint: l10n.emailHint,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.email(),
            ]),
          ),
          const SizedBox(height: 16),
          BuiltTextfield(
            name: 'location',
            label: l10n.locationLabel,
            hint: l10n.locationHint,
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 16),
          BuiltTextfield(
            name: 'phone',
            label: l10n.phoneLabel,
            hint: l10n.phoneHint,
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 16),
          BuiltTextfield(
            name: 'Profile',
            label: l10n.personalSummaryLabel,
            hint: l10n.personalSummaryHint,
            maxLine: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildExperiencePage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.workExperience,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.workExperienceSubtitle,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
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
            label: Text(l10n.addExperience),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(55),
              side: BorderSide(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationPage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.educationTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.educationSubtitle,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
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
            label: Text(l10n.addEducation),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(55),
              side: BorderSide(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsLanguagesPage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.skillsLanguages,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.skillsLanguagesSubtitle,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          BuiltTextfield(
            name: 'skills',
            label: l10n.skillsLabel,
            hint: l10n.skillsHint,
            maxLine: 3,
          ),
          const SizedBox(height: 16),
          BuiltTextfield(
            name: 'languages',
            label: l10n.languagesLabel,
            hint: l10n.languagesHint,
            maxLine: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildReferencesPage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.referencesTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.referencesSubtitle,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
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
            label: Text(l10n.addReference),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(55),
              side: BorderSide(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousPage,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    l10n.backButton,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (_currentPage > 0) const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                onPressed: _nextPage,
                label: _currentPage == _totalPages - 1
                    ? l10n.previewExport
                    : l10n.nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previewCV() {
    final l10n = AppLocalizations.of(context);
    if (_formKey.currentState!.saveAndValidate()) {
      final values = _formKey.currentState!.value;

      final skillsString = (values['skills'] as String?) ?? '';
      final skills = skillsString
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final languagesString = (values['languages'] as String?) ?? '';
      final languages = languagesString
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final cv = CvEntity(
        id: widget.initialCv?.id ?? 0,
        title: '${values['fullName']} - CV',
        templateName: widget.selectedTemplate.name,
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

      cv.exp.addAll(_experiences);
      cv.edu.addAll(_educations);
      cv.ref.addAll(_references);

      // Save to database
      ref.read(cvRepositoryProvider).saveCv(cv);

      _navigateToTemplate(cv);
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fixPersonalInfoError)));
    }
  }

  void _navigateToTemplate(CvEntity cv) {
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
