import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/create_resume.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/cv_form_screen.dart';
import 'package:job_finder/features/job_seeker/data/model/template_model.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/action_button.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/resume_card.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/cv_pdf_preview_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/providers/cv_provider.dart';
import 'package:intl/intl.dart';
import 'package:job_finder/l10n/app_localizations.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class MyDocumentPage extends ConsumerWidget {
  const MyDocumentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cvListAsync = ref.watch(cvListProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          l10n.myResumes,
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
                      label: l10n.newResume,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuildTemplate(),
                          ),
                        );
                        // Refresh the list after returning
                        ref.invalidate(cvListProvider);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionButton(
                      icon: 'assets/image/cover_letter.webp',
                      label: l10n.coverLetter,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.featureSoonMessage,
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
                l10n.myResumes,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Resume List
            Expanded(
              child: cvListAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text(l10n.errorLabel(error.toString()))),
                data: (cvList) => cvList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 64,
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noResumesYet,
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.createFirstResume,
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
                        itemCount: cvList.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final cv = cvList[index];
                          final dateFormat = DateFormat('dd MMM yyyy');

                          // Calculate progress based on filled fields
                          double progress = 0.3; // Base progress
                          if (cv.summary?.isNotEmpty ?? false) progress += 0.2;
                          if (cv.exp.isNotEmpty) progress += 0.25;
                          if (cv.edu.isNotEmpty) progress += 0.25;

                          return Dismissible(
                            key: Key(cv.id.toString()),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(l10n.deleteCvTitle),
                                  content: Text(l10n.deleteCvConfirm),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(l10n.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(
                                        l10n.deleteLabel,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              ref.read(cvListProvider.notifier).deleteCv(cv.id);
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const AppSvgIcon(
                                assetName: AppIcon.delete,
                                color: Colors.red,
                              ),
                            ),
                            child: ResumeCard(
                              title: cv.title,
                              template: cv.templateName,
                              progress: progress,
                              date: dateFormat.format(cv.updatedAt),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CvPdfPreviewScreen(
                                      cv: cv,
                                      templateName: cv.templateName,
                                    ),
                                  ),
                                );
                              },
                              onEdit: () async {
                                // 1. Find the correct template model from the global list
                                final template = allTemp.firstWhere(
                                  (t) => t.name == cv.templateName,
                                  orElse: () => allTemp.first,
                                );

                                // 2. Navigate to form with initial data
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CvFormScreen(
                                      selectedTemplate: template,
                                      initialCv: cv,
                                    ),
                                  ),
                                );

                                // 3. Refresh list after return
                                ref.invalidate(cvListProvider);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
