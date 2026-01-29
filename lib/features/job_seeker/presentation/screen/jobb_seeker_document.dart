import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/create_resume.dart';
import 'package:job_finder/features/job_seeker/presentation/screens/template_selection_screen.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/action_button.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/resume_card.dart';
import 'package:job_finder/features/job_seeker/presentation/providers/cv_provider.dart';
import 'package:intl/intl.dart';

class MyDocumentPage extends ConsumerStatefulWidget {
  const MyDocumentPage({super.key});

  @override
  ConsumerState<MyDocumentPage> createState() => _MyDocumentPageState();
}

class _MyDocumentPageState extends ConsumerState<MyDocumentPage> {
  List<CvEntity> _cvList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCvs();
  }

  Future<void> _loadCvs() async {
    setState(() => _isLoading = true);
    final cvs = await ref.read(cvRepositoryProvider).getAllCvs();
    setState(() {
      _cvList = cvs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'My Documents',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: ActionButton(
                      icon: 'assets/image/cv.png',
                      label: 'New resume',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuildTemplate(),
                          ),
                        );
                        _loadCvs(); // Reload after creating new CV
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionButton(
                      icon: 'assets/image/cover_letter.webp',
                      label: 'Cover letter',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'We will add this feature soon, stay tuned!',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            backgroundColor: colorScheme.surface,
                            behavior: SnackBarBehavior.fixed,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // My Resumes Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'My Resumes',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Resume List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _cvList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No resumes yet',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first resume to get started',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _cvList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cv = _cvList[index];
                        final dateFormat = DateFormat('dd MMM yyyy');

                        // Calculate progress based on filled fields
                        double progress = 0.3; // Base progress
                        if (cv.summary?.isNotEmpty ?? false) progress += 0.2;
                        if (cv.exp.isNotEmpty) progress += 0.25;
                        if (cv.edu.isNotEmpty) progress += 0.25;

                        return ResumeCard(
                          title: cv.title,
                          template: 'Normal', // Default template for now
                          progress: progress,
                          date: dateFormat.format(cv.updatedAt),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TemplateSelectionScreen(cv: cv),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
