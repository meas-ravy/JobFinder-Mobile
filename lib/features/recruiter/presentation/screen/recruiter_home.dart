import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/recruiter/data/models/job_card_data.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/recruiter/presentation/screen/widgets/job_card_widget.dart';
import 'package:job_finder/features/recruiter/presentation/screen/widgets/recruiter_header_section.dart';
import 'package:job_finder/features/recruiter/presentation/screen/widgets/recruiter_home_shimmer.dart';

class RecruiterHomePage extends HookConsumerWidget {
  const RecruiterHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final recruiterState = ref.watch(recruiterControllerProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 80,
          title: const RecruiterHeaderSection(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Column(
              children: [
                TabBar(
                  dividerColor: colorScheme.outline.withValues(alpha: 0.05),
                  indicatorColor: colorScheme.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Active Post'),
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Previous'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: recruiterState.isLoading
            ? const RecruiterHomeShimmer()
            : TabBarView(
                children: [
                  _buildJobsList(
                    ref,
                    recruiterState.jobs,
                    'No active jobs found',
                  ),
                  _buildJobsList(
                    ref,
                    recruiterState.draftJobs,
                    'No draft jobs found',
                  ),
                  _buildJobsList(ref, [], 'No previous jobs found'),
                ],
              ),
      ),
    );
  }

  Widget _buildJobsList(
    WidgetRef ref,
    List<dynamic> jobs,
    String emptyMessage,
  ) {
    final recruiterState = ref.watch(recruiterControllerProvider);

    if (jobs.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(
            color: Theme.of(ref.context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: jobs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final job = jobs[index] as DataMap;
        final jobId = job['_id'] ?? job['id'];
        return JobCard(
          data: JobCardData.fromJson(
            job,
            fallbackCompany: recruiterState.company,
          ),
          isLoading:
              recruiterState.isLoading && recruiterState.activeJobId == jobId,
          onStatusUpdate: (status) {
            if (status == 'edit') {
              context.push(AppPath.postJob, extra: job);
            } else if (status == 'delete') {
              _showDeleteConfirmation(context, ref, job['_id'] ?? job['id']);
            } else if (status == 'submit') {
              ref
                  .read(recruiterControllerProvider.notifier)
                  .submitJob(job['_id'] ?? job['id']);
            } else {
              ref
                  .read(recruiterControllerProvider.notifier)
                  .updateJobStatus(job['_id'] ?? job['id'], status);
            }
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String jobId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job Draft'),
        content: const Text(
          'Are you sure you want to delete this job draft? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(recruiterControllerProvider.notifier).deleteJob(jobId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
