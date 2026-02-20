import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/recruiter/data/models/job_card_data.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/recruiter/presentation/screen/widgets/job_card_widget.dart';
import 'package:job_finder/features/recruiter/presentation/screen/widgets/recruiter_home_shimmer.dart';
import 'package:job_finder/features/recruiter/presentation/widget/header_section.dart';

class RecruiterHomePage extends HookConsumerWidget {
  const RecruiterHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final recruiterState = ref.watch(recruiterControllerProvider);
    final activeTab = ref.watch(recruiterHomeTabProvider);

    final tabController = useTabController(initialLength: 5);

    // Sync tab index with provider
    useEffect(() {
      tabController.index = activeTab;
      return null;
    }, [activeTab]);

    // Update provider when tab changes manually
    useEffect(() {
      void listener() {
        if (!tabController.indexIsChanging) {
          ref.read(recruiterHomeTabProvider.notifier).state =
              tabController.index;
        }
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        title: const HeaderSection(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              TabBar(
                controller: tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorColor: colorScheme.primary,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 4,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 4, color: colorScheme.primary),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
                labelStyle: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
                unselectedLabelStyle: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                tabs: const [
                  Tab(text: 'Active Job'),
                  Tab(text: 'Draft Job'),
                  Tab(text: 'Paused Job'),
                  Tab(text: 'Rejected Job'),
                  Tab(text: 'Expired Job'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Divider(
                  height: 1,
                  color: colorScheme.outline.withValues(alpha: 0.05),
                ),
              ),
            ],
          ),
        ),
      ),
      body: recruiterState.isLoading
          ? const RecruiterHomeShimmer()
          : TabBarView(
              controller: tabController,
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
                _buildJobsList(
                  ref,
                  recruiterState.pausedJobs,
                  'No paused jobs found',
                ),
                _buildJobsList(
                  ref,
                  recruiterState.rejectedJobs,
                  'No rejected jobs found',
                ),
                _buildJobsList(
                  ref,
                  recruiterState.previousJobs,
                  'No previous jobs found',
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (recruiterState.company == null) {
            _showProfileRestrictionDialog(context);
          } else {
            context.push(AppPath.postJob);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        tooltip: 'Post a Job',
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.primaryLight,
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryLight.withValues(alpha: 0.3),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
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
          isLoading: recruiterState.activeJobId == jobId,
          onStatusUpdate: (status) {
            if (status == 'edit') {
              context.push(AppPath.postJob, extra: job);
            } else if (status == 'delete') {
              _showDeleteConfirmation(context, ref, job['_id'] ?? job['id']);
            } else if (status == 'submit' || status == 'resubmit') {
              ref
                  .read(recruiterControllerProvider.notifier)
                  .submitJob(job['_id'] ?? job['id']);
            } else if (status == 'view_candidates') {
              context.push(AppPath.viewApplicants, extra: jobId);
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

  void _showProfileRestrictionDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Required'),
        content: Text(
          'Before you can post your first job, you need to set up your company profile. This helps candidates know who they are applying to!',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(AppPath.createCompany);
            },
            child: const Text('Set Up Profile'),
          ),
        ],
      ),
    );
  }
}
