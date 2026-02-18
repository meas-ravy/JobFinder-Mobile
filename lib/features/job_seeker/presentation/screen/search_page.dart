import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/search_controller.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/filter_bottom_sheet.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/job_seeker_card.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:shimmer/shimmer.dart';

class SearchPage extends HookConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final searchController = useTextEditingController();
    final focusNode = useFocusNode();
    final debounceTimer = useRef<Timer?>(null);

    // Auto-focus the search field on open
    useEffect(() {
      Future.microtask(() => focusNode.requestFocus());
      return () => debounceTimer.value?.cancel();
    }, []);

    void performSearch(String query) {
      debounceTimer.value?.cancel();
      debounceTimer.value = Timer(const Duration(milliseconds: 500), () {
        ref
            .read(searchControllerProvider.notifier)
            .searchJobs(query, filters: searchState.filters);
      });
    }

    void openFilterSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FilterBottomSheet(
          currentFilters: searchState.filters,
          onApply: (filters) {
            ref.read(searchControllerProvider.notifier).applyFilters(filters);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () {
            ref.read(searchControllerProvider.notifier).clearSearch();
            Navigator.of(context).pop();
          },
        ),
        title: Container(
          height: 50,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColor.cardDark : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: TextField(
            controller: searchController,
            focusNode: focusNode,
            onChanged: performSearch,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Search for a job or company',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: AppSvgIcon(
                  assetName: AppIcon.search,
                  color: Colors.grey[500],
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        searchController.clear();
                        ref
                            .read(searchControllerProvider.notifier)
                            .clearSearch();
                      },
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey[500],
                      ),
                    ),
                  IconButton(
                    onPressed: openFilterSheet,
                    icon: Stack(
                      children: [
                        const Icon(
                          Icons.tune,
                          color: AppColor.primaryDark,
                          size: 22,
                        ),
                        if (searchState.filters.hasActiveFilters)
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
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(context, ref, searchState, isDark, theme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    dynamic searchState,
    bool isDark,
    ThemeData theme,
  ) {
    // Initial state - nothing searched yet
    if (!searchState.hasSearched) {
      return _buildInitialState(isDark, theme);
    }

    // Loading
    if (searchState.isLoading) {
      return _buildShimmerList(isDark);
    }

    // Empty results
    if (searchState.results.isEmpty) {
      return _buildEmptyState(isDark, theme);
    }

    // Results
    return Column(
      children: [
        // Results count + filter icon
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatCount(searchState.totalCount)} found',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.sort,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 22,
              ),
            ],
          ),
        ),

        // Job list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: searchState.results.length,
            itemBuilder: (context, index) {
              final job = searchState.results[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: JobSeekerCard(job: job, isHorizontal: true),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInitialState(bool isDark, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 80,
              color: AppColor.primaryDark.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Search for Jobs',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find your dream job by searching for a title, company, or keyword',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sad face illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColor.primaryDark.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 64,
                color: AppColor.primaryDark.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Not Found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sorry, the keyword you entered cannot be found, please check again or search with another keyword',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return count.toString();
  }
}
