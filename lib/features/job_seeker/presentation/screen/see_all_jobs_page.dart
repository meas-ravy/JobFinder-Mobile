import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_provider.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/category_chip.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/job_seeker_card.dart';
import 'package:shimmer/shimmer.dart';

enum SeeAllType { recommended, recent }

class SeeAllJobsPage extends HookConsumerWidget {
  final SeeAllType type;

  const SeeAllJobsPage({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobState = ref.watch(jobControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedCategory = useState('All');

    final categories = [
      'All',
      'Technology',
      'Healthcare',
      'Finance',
      'Education',
      'Marketing',
      'Sales',
      'Engineering',
      'Design',
      'CustomerService',
      'HumanResources',
      'Operations',
      'Legal',
      'Construction',
      'Retail',
      'Hospitality',
      'Manufacturing',
      'Transportation',
      'RealEstate',
      'Media',
      'Other',
    ];

    final isRecommended = type == SeeAllType.recommended;
    final jobs = isRecommended ? jobState.recommendedJobs : jobState.recentJobs;
    final isLoading = isRecommended
        ? jobState.isLoading
        : jobState.isRecentLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isRecommended ? 'Recommended Jobs' : 'Recent Jobs',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          if (!isRecommended) ...[
            SizedBox(
              height: 52,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CategoryChip(
                      label: categories[index],
                      isSelected: selectedCategory.value == categories[index],
                      onTap: () {
                        if (selectedCategory.value != categories[index]) {
                          selectedCategory.value = categories[index];
                          ref
                              .read(jobControllerProvider.notifier)
                              .fetchRecentJob(category: categories[index]);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Jobs list
          Expanded(
            child: isLoading
                ? _buildShimmerList(isDark)
                : jobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_off_outlined,
                          size: 64,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isRecommended
                              ? 'No recommended jobs found'
                              : 'No jobs found in this category',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: AppColor.primaryDark,
                    onRefresh: () async {
                      if (isRecommended) {
                        await ref
                            .read(jobControllerProvider.notifier)
                            .fetchRecomJob();
                      } else {
                        await ref
                            .read(jobControllerProvider.notifier)
                            .fetchRecentJob(category: selectedCategory.value);
                      }
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: JobSeekerCard(job: job, isHorizontal: true),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[900]! : Colors.grey[100]!,
            highlightColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      },
    );
  }
}
