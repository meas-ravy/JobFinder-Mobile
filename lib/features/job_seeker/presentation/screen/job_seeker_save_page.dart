import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_provider.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/job_seeker_card.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/search_state.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/filter_bottom_sheet.dart';

class JobSeekerSavePage extends HookConsumerWidget {
  const JobSeekerSavePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final savedJobsAsync = ref.watch(savedJobsProvider);
    final searchController = useTextEditingController();
    final selectedFilters = useState<SearchFilters>(const SearchFilters());
    // Re-build when search or filters change
    useValueListenable(searchController);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            Text(
              'Saved Jobs',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? AppColor.cardDark : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: searchController,
                cursorColor: AppColor.primaryDark,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search saved jobs...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AppSvgIcon(
                      assetName: AppIcon.search,
                      color: Colors.grey[400],
                    ),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (searchController.text.isNotEmpty)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => searchController.clear(),
                        ),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => FilterBottomSheet(
                              currentFilters: selectedFilters.value,
                              onApply: (newFilters) =>
                                  selectedFilters.value = newFilters,
                            ),
                          );
                        },
                        icon: Stack(
                          children: [
                            const Icon(
                              Icons.tune,
                              color: AppColor.primaryDark,
                              size: 22,
                            ),
                            if (selectedFilters.value.hasActiveFilters)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Job List
          Expanded(
            child: savedJobsAsync.when(
              data: (jobs) {
                final query = searchController.text.toLowerCase();
                final filters = selectedFilters.value;

                final filteredJobs = jobs.where((job) {
                  // Text Search
                  final matchesQuery =
                      job.title.toLowerCase().contains(query) ||
                      (job.companyProfile?.name.toLowerCase().contains(query) ??
                          false);
                  if (!matchesQuery) return false;

                  // Active Filters
                  if (filters.location != null &&
                      filters.location!.isNotEmpty) {
                    if (!(job.location?.toLowerCase().contains(
                          filters.location!.toLowerCase(),
                        ) ??
                        false))
                      return false;
                  }
                  if (filters.category != null &&
                      filters.category!.isNotEmpty &&
                      filters.category != 'Other') {
                    if (job.category != filters.category) return false;
                  }
                  if (filters.workArrangement != null &&
                      filters.workArrangement!.isNotEmpty) {
                    if (job.workArrangement != filters.workArrangement)
                      return false;
                  }
                  if (filters.experienceLevel != null &&
                      filters.experienceLevel!.isNotEmpty) {
                    if (job.experienceLevel != filters.experienceLevel)
                      return false;
                  }
                  if (filters.employmentType != null &&
                      filters.employmentType!.isNotEmpty) {
                    if (job.employmentType != filters.employmentType)
                      return false;
                  }
                  if (filters.salaryMin != null) {
                    if ((job.salaryMin ?? 0) < filters.salaryMin!) return false;
                  }
                  if (filters.salaryMax != null) {
                    if ((job.salaryMax ?? double.infinity) > filters.salaryMax!)
                      return false;
                  }

                  return true;
                }).toList();

                if (jobs.isEmpty) {
                  return _buildEmptyState(isDark, theme);
                }

                if (filteredJobs.isEmpty) {
                  return _buildNoResultsState(
                    isDark,
                    theme,
                    searchController.text,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(savedJobsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: filteredJobs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) =>
                        JobSeekerCard(job: filteredJobs[index]),
                  ),
                );
              },
              loading: () => _buildLoadingState(isDark),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColor.primaryDark.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: AppSvgIcon(
              assetName: AppIcon.save,
              size: 64,
              color: AppColor.primaryDark,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Saved Jobs Yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Keep track of jobs that interest you\nby tapping the bookmark icon.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(bool isDark, ThemeData theme, String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSvgIcon(
            assetName: AppIcon.search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find anything for "$query"',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[900]! : Colors.grey[200]!,
        highlightColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
