import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/ai_assistant_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder/core/routes/app_path.dart';

class AiMatchReportScreen extends HookConsumerWidget {
  final bool isDark;
  final String jobDescription;

  const AiMatchReportScreen({
    super.key,
    required this.isDark,
    required this.jobDescription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiAssistantControllerProvider);
    final controller = ref.read(aiAssistantControllerProvider.notifier);

    // Initial call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.result == null && !state.isLoading && state.error == null) {
        controller.analyzeJobMatch(jobDescription);
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColor.backgroundColorDark : Colors.white,
      appBar: AppBar(
        title: const Text('AI Match Analysis'),
        backgroundColor: isDark ? AppColor.backgroundColorDark : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (state.isLoading)
              _buildLoadingState()
            else if (state.error != null)
              _buildErrorState(context, state.error!)
            else if (state.result != null)
              _buildReport(state.result!)
            else
              const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 150),
          const CircularProgressIndicator(color: AppColor.primaryDark),
          const SizedBox(height: 24),
          const Text(
            'Jober is analyzing your Resume...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    if (error == 'NO_RESUME') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const Icon(
            Icons.description_outlined,
            color: AppColor.primaryDark,
            size: 80,
          ),
          const SizedBox(height: 24),
          const Text(
            'Resume Required',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'To analyze this job, we need to look at your professional profile. Please build your resume first.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(AppPath.buildTemplate);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Create Resume Now',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildReport(dynamic result) {
    final score = result.matchScore;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        score > 70 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                  Text(
                    '$score%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Match Score',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _buildSectionHeader('AI Summary', Icons.auto_awesome),
        const SizedBox(height: 12),
        Text(
          result.relevanceSummary,
          style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 16),
        ),
        const SizedBox(height: 32),
        _buildSectionHeader('Top Gaps', Icons.warning_amber_rounded),
        const SizedBox(height: 12),
        ...result.topGaps.map(
          (gap) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(gap, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionHeader('Mentor Advice', Icons.lightbulb_outline),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColor.primaryDark.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.primaryDark.withOpacity(0.1)),
          ),
          child: Text(
            result.advice,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColor.primaryDark, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ],
    );
  }
}
