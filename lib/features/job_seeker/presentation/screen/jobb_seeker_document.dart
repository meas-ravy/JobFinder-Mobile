import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/action_button.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/resume_card.dart';

class MyDocumentPage extends StatelessWidget {
  const MyDocumentPage({super.key});

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
                      onTap: () {
                        context.push(AppPath.buildTemplate);
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ResumeCard(
                    title: 'UI / UX Designer',
                    template: 'Prague',
                    progress: 0.85,
                    date: '12 May 2023',
                    onTap: () {
                      // Navigate to edit resume
                    },
                  ),
                  const SizedBox(height: 12),
                  ResumeCard(
                    title: 'Graphic Designer',
                    template: 'Simple',
                    progress: 0.55,
                    date: '14 May 2023',
                    onTap: () {
                      // Navigate to edit resume
                    },
                  ),
                  const SizedBox(height: 12),
                  ResumeCard(
                    title: 'Product Designer',
                    template: 'Simple',
                    progress: 0.25,
                    date: '11 May 2023',
                    onTap: () {
                      // Navigate to edit resume
                    },
                  ),
                  const SizedBox(height: 12),
                  ResumeCard(
                    title: 'Designer',
                    template: 'Modern',
                    progress: 0.15,
                    date: '10 May 2023',
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
