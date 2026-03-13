import 'dart:math';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/recruiter/presentation/widget/header_section.dart';
import 'package:job_finder/features/recruiter/presentation/widget/radar_chart.dart';
import 'package:job_finder/features/recruiter/presentation/widget/stats_widgets.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';

class RecruiterStatsPage extends HookConsumerWidget {
  const RecruiterStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final recruiterState = ref.watch(recruiterDashboardControllerProvider);
    final dashboardData = recruiterState.dashboardData;
    final summary = dashboardData?['summary'] as Map<String, dynamic>? ?? {};
    final chartData =
        dashboardData?['chart'] as List<dynamic>? ??
        List.generate(
          12,
          (index) => {'month': '', 'applied': 0, 'interview': 0, 'confirm': 0},
        );
    final jobs = dashboardData?['jobs'] as List<dynamic>? ?? [];

    useEffect(() {
      // Only fetch if data is not already loaded → avoids re-fetching on every tab switch
      if (ref.read(recruiterDashboardControllerProvider).dashboardData == null) {
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            ref
                .read(recruiterDashboardControllerProvider.notifier)
                .getRecruiterDashboard();
          }
        });
      }
      return null;
    }, []);

    final tabController = useTabController(initialLength: 3);
    final tabIndex = useListenableSelector(
      tabController,
      () => tabController.index,
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        title: const HeaderSection(),
      ),
      body: recruiterState.isLoading && dashboardData == null
          ? const _StatsShimmer()
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(recruiterDashboardControllerProvider.notifier)
                    .getRecruiterDashboard();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last 1 Year',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildRadarCard(colorScheme, textTheme, chartData),
                    const SizedBox(height: 16),
                    _buildLegend(colorScheme, summary),
                    const SizedBox(height: 20),
                    TabBar(
                      controller: tabController,
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
                        Tab(text: 'Applied'),
                        Tab(text: 'Interview'),
                        Tab(text: 'Confirm'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (jobs.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text('No job statistics available'),
                        ),
                      )
                    else
                      Builder(
                        builder: (context) {
                          final type = tabIndex == 0
                              ? 'applied'
                              : (tabIndex == 1 ? 'interview' : 'confirm');
                          // Compute max to show relative progress rings
                          final maxCount = jobs.fold<int>(0, (prev, item) {
                            final v = (item[type] as num? ?? 0).toInt();
                            return v > prev ? v : prev;
                          });
                          return Column(
                            children: [
                              ...jobs.map((item) {
                                final count = (item[type] as num? ?? 0).toInt();
                                if (count == 0 && jobs.length > 3) {
                                  return const SizedBox.shrink();
                                }
                                final percent = maxCount > 0
                                    ? (count / maxCount) * 100
                                    : 0.0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildJobStatTile(
                                    item['title']?.toString() ?? 'Unknown Job',
                                    count,
                                    percent,
                                    type.capitalize(),
                                    colorScheme,
                                    textTheme,
                                    context,
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildJobStatTile(
    String title,
    int count,
    double percent,
    String label,
    ColorScheme colorScheme,
    TextTheme textTheme,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ProgressRing(
            percent: percent,
            color: colorScheme.primary,
            count: '+$count',
          ),
        ],
      ),
    );
  }

  Widget _buildRadarCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    List<dynamic> chartData,
  ) {
    if (chartData.isEmpty) return const SizedBox.shrink();

    final labels = chartData.map((e) => e['month']?.toString() ?? '').toList();
    final appliedValues = chartData
        .map((e) => (e['applied'] as num? ?? 0).toDouble())
        .toList();
    final interviewValues = chartData
        .map((e) => (e['interview'] as num? ?? 0).toDouble())
        .toList();
    final confirmValues = chartData
        .map((e) => (e['confirm'] as num? ?? 0).toDouble())
        .toList();

    final dataSets = [
      RadarDataSet(
        values: appliedValues,
        strokeColor: const Color(0xFF22D38A),
        fillColor: const Color(0xFF22D38A).withValues(alpha: 0.16),
      ),
      RadarDataSet(
        values: interviewValues,
        strokeColor: colorScheme.primary,
        fillColor: colorScheme.primary.withValues(alpha: 0.16),
      ),
      RadarDataSet(
        values: confirmValues,
        strokeColor: colorScheme.tertiary,
        fillColor: colorScheme.tertiary.withValues(alpha: 0.16),
      ),
    ];

    double maxValue = 10;
    for (var e in chartData) {
      maxValue = max(
        maxValue,
        max(
          (e['applied'] as num? ?? 0).toDouble(),
          max(
            (e['interview'] as num? ?? 0).toDouble(),
            (e['confirm'] as num? ?? 0).toDouble(),
          ),
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return RadarChart(
            labels: labels,
            dataSets: dataSets,
            maxValue: maxValue,
            animationValue: value,
            labelStyle: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
            gridColor: colorScheme.outlineVariant.withValues(alpha: 0.2),
          );
        },
      ),
    );
  }

  Widget _buildLegend(ColorScheme colorScheme, Map<String, dynamic> summary) {
    return Column(
      children: [
        LegendRow(
          color: const Color(0xFF22D38A),
          label: 'Applied',
          value: summary['applied']?.toString() ?? '0',
        ),
        const SizedBox(height: 16),
        DottedLine(
          dashColor: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 16),
        LegendRow(
          color: colorScheme.primary,
          label: 'Interview',
          value: summary['interview']?.toString() ?? '0',
        ),
        const SizedBox(height: 16),
        DottedLine(
          dashColor: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 16),
        LegendRow(
          color: colorScheme.tertiary,
          label: 'Confirm',
          value: summary['confirm']?.toString() ?? '0',
        ),
      ],
    );
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(width: 150, height: 24),
          const SizedBox(height: 20),
          const ShimmerLoading(
            width: double.infinity,
            height: 260,
            borderRadius: 20,
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < 3; i++) ...[
            const ShimmerLoading(width: double.infinity, height: 40),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 20),
          const ShimmerLoading(
            width: double.infinity,
            height: 48,
            borderRadius: 24,
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < 3; i++) ...[
            const ShimmerLoading(
              width: double.infinity,
              height: 80,
              borderRadius: 16,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
