import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:job_finder/features/recruiter/domain/models/candidate_stat.dart';
import 'package:job_finder/features/recruiter/presentation/widget/header_section.dart';
import 'package:job_finder/features/recruiter/presentation/widget/radar_chart.dart';
import 'package:job_finder/features/recruiter/presentation/widget/stats_widgets.dart';

class RecruiterStatsPage extends StatefulWidget {
  const RecruiterStatsPage({super.key});

  @override
  State<RecruiterStatsPage> createState() => _RecruiterStatsPageState();
}

class _RecruiterStatsPageState extends State<RecruiterStatsPage> {
  final List<CandidateStat> _candidates = const [
    CandidateStat(
      role: 'Product designer',
      name: 'Akbar Rahman',
      percent: 78,
      color: Color(0xFF22D38A),
      count: 120,
    ),
    CandidateStat(
      role: 'Web designer',
      name: 'Erman Ermin',
      percent: 85,
      color: Color(0xFF22D38A),
      count: 230,
    ),
    CandidateStat(
      role: 'Marketing Manager',
      name: 'Arfata Nayeem',
      percent: 70,
      color: Color(0xFF22D38A),
      count: 85,
    ),
    CandidateStat(
      role: 'Graphic Design',
      name: 'Wasmihy Chy',
      percent: 60,
      color: Color(0xFF22D38A),
      count: 45,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 80,
          title: const HeaderSection(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last 1 Years',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(
                          '1 Years',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildRadarCard(colorScheme, textTheme),
              const SizedBox(height: 16),
              _buildLegend(colorScheme),
              const SizedBox(height: 20),
              TabBar(
                dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.2),
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
              ..._candidates.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCandidateTile(item, colorScheme, textTheme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateTile(
    CandidateStat item,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.role,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Applied',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ProgressRing(
            percent: item.percent,
            color: colorScheme.primary,
            count: '+${item.count}',
          ),
        ],
      ),
    );
  }

  Widget _buildRadarCard(ColorScheme colorScheme, TextTheme textTheme) {
    final labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    final dataSets = [
      RadarDataSet(
        values: const [88, 92, 70, 68, 76, 80, 90],
        strokeColor: colorScheme.primary,
        fillColor: colorScheme.primary.withValues(alpha: 0.16),
      ),
      RadarDataSet(
        values: const [62, 68, 50, 48, 55, 60, 65],
        strokeColor: colorScheme.secondary,
        fillColor: colorScheme.secondary.withValues(alpha: 0.16),
      ),
      RadarDataSet(
        values: const [40, 46, 30, 28, 35, 38, 42],
        strokeColor: colorScheme.tertiary,
        fillColor: colorScheme.tertiary.withValues(alpha: 0.16),
      ),
    ];

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
            maxValue: 100,
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

  Widget _buildLegend(ColorScheme colorScheme) {
    return Column(
      children: [
        LegendRow(
          color: const Color(0xFF22D38A),
          label: 'Applied',
          value: '1500',
        ),
        const SizedBox(height: 16),
        DottedLine(
          dashColor: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 16),
        LegendRow(color: colorScheme.primary, label: 'Interview', value: '750'),
        const SizedBox(height: 16),
        DottedLine(
          dashColor: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 16),
        LegendRow(
          color: colorScheme.tertiary,
          label: 'Job Confirm',
          value: '180',
        ),
      ],
    );
  }
}
