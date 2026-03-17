import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/notifications/presentation/provider/notification_provider.dart';
import 'package:job_finder/features/recruiter/data/models/job_card_data.dart';
import 'package:job_finder/features/recruiter/presentation/provider/company/company_profile_controller.dart';
import 'package:job_finder/features/recruiter/presentation/provider/company/company_profile_state.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/recruiter/presentation/widget/header_section.dart';
import 'package:job_finder/features/recruiter/presentation/widget/job_card_widget.dart';
import 'package:job_finder/features/recruiter/presentation/widget/recruiter_home_shimmer.dart';
import 'package:job_finder/core/provider/scroll_provider.dart';

class RecruiterHomePage extends HookConsumerWidget {
  const RecruiterHomePage({super.key});

  // Tab metadata: label, icon, color
  static const _tabs = [
    (
      label: 'Active',
      icon: Icons.check_circle_rounded,
      color: Color(0xFF22D38A),
    ),
    (label: 'Draft', icon: Icons.edit_note_rounded, color: Color(0xFF246BFD)),
    (
      label: 'Paused',
      icon: Icons.pause_circle_rounded,
      color: Color(0xFFF1C65A),
    ),
    (label: 'Rejected', icon: Icons.cancel_rounded, color: Color(0xffFE5151)),
    (label: 'Expired', icon: Icons.timer_off_rounded, color: Color(0xFF8A94A8)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.microtask(() {
        ref.read(notificationControllerProvider.notifier).getNotifications();
        final state = GoRouterState.of(context);
        final subTab = state.uri.queryParameters['subTab'];
        if (subTab != null) {
          final index = int.tryParse(subTab);
          if (index != null) {
            ref.read(recruiterHomeTabProvider.notifier).state = index;
            // call refresh all job when deep link navigation to ative refresh page
            ref.read(recruiterJobsControllerProvider.notifier).refreshAllJobs();
          }
        }
      });
      return null;
    }, [GoRouterState.of(context).uri.queryParameters['subTab']]);
    final jobsState = ref.watch(recruiterJobsControllerProvider);
    final companyState = ref.watch(companyProfileProvider);
    final activeTab = ref.watch(recruiterHomeTabProvider);

    final currentJobs = _getJobsForTab(activeTab, jobsState);
    final emptyMessages = [
      'No active jobs yet',
      'No draft jobs yet',
      'No paused jobs yet',
      'No rejected jobs yet',
      'No expired jobs yet',
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        title: const HeaderSection(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  children: List.generate(_tabs.length, (i) {
                    return _filterChip(
                      context: context,
                      ref: ref,
                      index: i,
                      activeTab: activeTab,
                    );
                  }),
                ),
              ),
              Divider(
                height: 1,
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.05),
              ),
            ],
          ),
        ),
      ),
      body: jobsState.isLoading
          ? const RecruiterHomeShimmer()
          : jobsState.isRefreshing
          ? const RecruiterHomeShimmer()
          : _buildJobsList(
              ref,
              currentJobs,
              emptyMessages[activeTab],
              companyState,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (companyState.company == null) {
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

  List<dynamic> _getJobsForTab(int tab, dynamic state) {
    switch (tab) {
      case 0:
        return state.jobs as List<dynamic>;
      case 1:
        return state.draftJobs as List<dynamic>;
      case 2:
        return state.pausedJobs as List<dynamic>;
      case 3:
        return state.rejectedJobs as List<dynamic>;
      case 4:
        return state.previousJobs as List<dynamic>;
      default:
        return [];
    }
  }

  Widget _filterChip({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required int activeTab,
  }) {
    final tab = _tabs[index];
    final isActive = activeTab == index;
    final colorScheme = Theme.of(context).colorScheme;
    final chipColor = tab.color;

    return GestureDetector(
      onTap: () => ref.read(recruiterHomeTabProvider.notifier).state = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? chipColor.withValues(alpha: 0.13)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive
                ? chipColor.withValues(alpha: 0.45)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: chipColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                tab.icon,
                key: ValueKey(isActive),
                size: 14,
                color: isActive
                    ? chipColor
                    : colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(width: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? chipColor
                    : colorScheme.onSurface.withValues(alpha: 0.45),
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsList(
    WidgetRef ref,
    List<dynamic> jobs,
    String emptyMessage,
    CompanyProfileState companyState,
  ) {
    final jobsState = ref.watch(recruiterJobsControllerProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(recruiterJobsControllerProvider.notifier).refreshAllJobs(),
          ref.read(notificationControllerProvider.notifier).getNotifications(),
        ]);
      },
      child: jobs.isEmpty
          ? SingleChildScrollView(
              controller: ref.watch(recruiterHomeScrollControllerProvider),
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(ref.context).size.height * 0.5,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Theme.of(
                            ref.context,
                          ).colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          emptyMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(
                              ref.context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(
                            color: Theme.of(ref.context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : ListView.separated(
              controller: ref.watch(recruiterHomeScrollControllerProvider),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: jobs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final jobItem = jobs[index];
                final job = (jobItem is Map)
                    ? DataMap.from(jobItem)
                    : <String, dynamic>{};
                final jobId = job['id'];
                return JobCard(
                  data: JobCardData.fromJson(
                    job,
                    fallbackCompany: companyState.company,
                  ),
                  isLoading: jobsState.activeJobId == jobId,
                  onStatusUpdate: (status) {
                    if (status == 'edit') {
                      context.push(AppPath.postJob, extra: job);
                    } else if (status == 'delete') {
                      _showDeleteConfirmation(context, ref, job['id']);
                    } else if (status == 'submit' || status == 'resubmit') {
                      ref
                          .read(recruiterJobsControllerProvider.notifier)
                          .submitJob(job['id']);
                    } else if (status == 'view_candidates') {
                      context.push('${AppPath.viewApplicants}/$jobId');
                    } else {
                      ref
                          .read(recruiterJobsControllerProvider.notifier)
                          .updateJobStatus(job['id'], status);
                    }
                  },
                );
              },
            ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String jobId,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    const dangerRed = Color(0xffFE5151);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: dangerRed.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Danger glow icon ──
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dangerRed.withValues(alpha: 0.1),
                    border: Border.all(
                      color: dangerRed.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: dangerRed.withValues(alpha: 0.15),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    size: 36,
                    color: dangerRed,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Title ──
                Text(
                  'Delete Job Draft?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),

                // ── Subtitle ──
                Text(
                  'This job draft will be permanently removed. This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Warning pill ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: dangerRed.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: dangerRed.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: dangerRed.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Permanent — cannot be recovered',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: dangerRed.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Delete CTA ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [dangerRed, dangerRed.withValues(alpha: 0.82)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: dangerRed.withValues(alpha: 0.30),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        ref
                            .read(recruiterJobsControllerProvider.notifier)
                            .deleteJob(jobId);
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.delete_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Yes, Delete Draft',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Cancel ──
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Keep Draft',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProfileRestrictionDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.08),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Glow icon ──
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.business_center_rounded,
                    size: 36,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Title ──
                Text(
                  'Set Up Your Company First',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),

                // ── Subtitle ──
                Text(
                  'Before posting a job, complete your company profile so candidates know who they\'re applying.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Feature chips ──
                Row(
                  children: [
                    _featureChip(
                      context,
                      Icons.verified_rounded,
                      'Builds trust',
                    ),
                    const SizedBox(width: 10),
                    _featureChip(
                      context,
                      Icons.visibility_rounded,
                      'More visibility',
                    ),
                    const SizedBox(width: 10),
                    _featureChip(
                      context,
                      Icons.people_rounded,
                      'More applicants',
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Primary CTA ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push(AppPath.createCompany);
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text(
                        'Set Up Company Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Secondary dismiss ──
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Maybe Later',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _featureChip(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
