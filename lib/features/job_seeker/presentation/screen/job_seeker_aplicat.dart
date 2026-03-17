import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/application_provider.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/search_state.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/application_card.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/filter_bottom_sheet.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:shimmer/shimmer.dart';
// import 'package:go_router/go_router.dart';
// import 'package:job_finder/core/routes/app_path.dart';

class JobSeekerAplicatPage extends HookConsumerWidget {
  const JobSeekerAplicatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final applicationsAsync = ref.watch(myApplicationsProvider);
    final searchController = useTextEditingController();
    final selectedFilters = useState<SearchFilters>(const SearchFilters());
    useValueListenable(searchController);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Applications',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
          const SizedBox(width: 8),
        ],
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
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search',
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // ignore: unused_result
                await ref.refresh(myApplicationsProvider.future);
              },
              child: applicationsAsync.when(
                data: (applications) {
                  final query = searchController.text.toLowerCase();
                  final filters = selectedFilters.value;

                  final filteredApps = applications.where((app) {
                    final job = app.job;
                    if (job == null) return false;

                    // Search logic
                    final matchesQuery =
                        job.title.toLowerCase().contains(query) ||
                        (job.companyProfile?.name.toLowerCase().contains(
                              query,
                            ) ??
                            false);
                    if (!matchesQuery) return false;

                    // Filter logic
                    if (filters.location != null &&
                        filters.location!.isNotEmpty) {
                      if (!(job.location?.toLowerCase().contains(
                            filters.location!.toLowerCase(),
                          ) ??
                          false)) {
                        return false;
                      }
                    }
                    if (filters.category != null &&
                        filters.category!.isNotEmpty &&
                        filters.category != 'Other') {
                      if (job.category != filters.category) return false;
                    }
                    if (filters.workArrangement != null &&
                        filters.workArrangement!.isNotEmpty) {
                      if (job.workArrangement != filters.workArrangement) {
                        return false;
                      }
                    }
                    if (filters.experienceLevel != null &&
                        filters.experienceLevel!.isNotEmpty) {
                      if (job.experienceLevel != filters.experienceLevel) {
                        return false;
                      }
                    }
                    if (filters.employmentType != null &&
                        filters.employmentType!.isNotEmpty) {
                      if (job.employmentType != filters.employmentType) {
                        return false;
                      }
                    }

                    return true;
                  }).toList();

                  if (applications.isEmpty) {
                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(theme, isDark),
                        ),
                      ],
                    );
                  }

                  if (filteredApps.isEmpty) {
                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildNoResultsState(
                            theme,
                            searchController.text,
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: filteredApps.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                    ),
                    itemBuilder: (context, index) => InkWell(
                      onTap: () async {
                        // context.push(
                        //   '${AppPath.jobSeekerApplicationDetail}/${filteredApps[index].id}',
                        // );
                      },
                      child: ApplicationCard(
                        key: ValueKey(filteredApps[index].id),
                        application: filteredApps[index],
                      ),
                    ),
                  );
                },
                loading: () => _buildLoadingState(isDark),
                error: (err, stack) => CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('Error: $err')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
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
            child: Icon(
              Icons.assignment_outlined,
              size: 60,
              color: AppColor.primaryDark,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Applications Yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Apply to jobs you are interested in\nto track them here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(ThemeData theme, String query) {
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: 5,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
      ),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 180,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 120,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 140,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
