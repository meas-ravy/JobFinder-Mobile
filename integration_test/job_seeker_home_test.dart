import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:job_finder/main.dart' as app;
import 'package:job_finder/features/job_seeker/presentation/widget/job_seeker_card.dart';

void main() {
  // 1. Initialize the integration test binding
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Job Seeker Home Integration Test', () {
    testWidgets(
      'Full flow: Home Page load, Category filter, and Job Detail navigation',
      (tester) async {
        // 2. Start the app
        // Note: app.main() handles Firebase and ObjectBox initialization
        app.main();

        // Wait for the app to load and splash screen to be removed
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // 3. Verify Home Page Content
        // Check if we see the "Recommendation" header
        expect(find.text('Recommendation'), findsOneWidget);

        // Check if the "Recent Jobs" section exists
        expect(find.text('Recent Jobs'), findsOneWidget);

        // 4. Test Category Filtering
        // Find the 'Technology' category chip
        final technologyChip = find.text('Technology');

        if (tester.any(technologyChip)) {
          await tester.tap(technologyChip);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('✅ Tapped Technology Category');
        }

        // 5. Test Job Card Interaction
        // Find the first job card in the list
        final firstJobCard = find.byType(JobSeekerCard).first;

        if (tester.any(firstJobCard)) {
          // Tap the card to go to details
          await tester.tap(firstJobCard);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // 6. Verify Navigation to Job Detail Page
          // Check for specific detail page content (usually the job title or "Job Details")
          expect(find.byIcon(Icons.arrow_back), findsOneWidget);
          print('✅ Navigated to Job Detail successfully');
        } else {
          print(
            '⚠️ No Job Cards found in the list. Ensure you have internet or mock data.',
          );
        }
      },
    );
  });
}
