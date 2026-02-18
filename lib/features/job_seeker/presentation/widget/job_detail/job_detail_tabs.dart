import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/job_detail/job_detail_info_card.dart';

class JobDetailTabs extends StatelessWidget {
  final JobEntity job;
  final bool isDark;
  final ThemeData theme;

  const JobDetailTabs({
    super.key,
    required this.job,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: JobDetailInfoCard(job: job, isDark: isDark, theme: theme),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              Container(
                color: isDark
                    ? AppColor.backgroundColorDark
                    : theme.scaffoldBackgroundColor,
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  indicatorColor: AppColor.primaryDark,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColor.primaryDark,
                  unselectedLabelColor: Colors.grey[500],
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  tabs: const [
                    Tab(text: 'Description'),
                    Tab(text: 'Responsibilities'),
                    Tab(text: 'Requirements'),
                    Tab(text: 'Skills'),
                    Tab(text: 'Perks'),
                    Tab(text: 'About Company'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: TabBarView(
            children: [
              _buildContentTab(
                'Job Description',
                job.description ?? '',
                theme.colorScheme,
              ),
              _buildContentListTab(
                'Responsibilities',
                job.responsibilities ?? '',
                theme.colorScheme,
              ),
              _buildContentListTab(
                'Requirements',
                job.requirements ?? '',
                theme.colorScheme,
              ),
              _buildSkillsTab(
                'Required Skills',
                job.skills ?? '',
                theme.colorScheme,
              ),
              _buildPerksTab(
                'Perks & Benefits',
                job.benefits ?? '',
                theme.colorScheme,
              ),
              _buildContentTab(
                'About Company',
                job.companyProfile?.description ?? '',
                theme.colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsTab(String title, String skills, ColorScheme colorScheme) {
    final skillList = skills
        .split(',')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .toList();

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text(
          '$title:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 20),
        if (skillList.isNotEmpty) ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: skillList.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColor.primaryDark, width: 1.5),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: AppColor.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildContentListTab(
    String title,
    String content,
    ColorScheme colorScheme,
  ) {
    final points = content
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text(
          '$title:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.circle,
                    size: 10,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    point.replaceFirst('•', '').trim(),
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerksTab(String title, String content, ColorScheme colorScheme) {
    final points = content
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text(
          '$title:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 20),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColor.primaryDark.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getBenefitIcon(point),
                    color: AppColor.primaryDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    point.replaceFirst('•', '').trim(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getBenefitIcon(String text) {
    final t = text.toLowerCase();
    if (t.contains('medical') ||
        t.contains('health') ||
        t.contains('insurance')) {
      return Icons.verified_user;
    }
    if (t.contains('prescription') ||
        t.contains('vision') ||
        t.contains('dental')) {
      return Icons.assignment_turned_in;
    }
    if (t.contains('bonus') ||
        t.contains('performance') ||
        t.contains('incentive')) {
      return Icons.insights;
    }
    if (t.contains('sick') || t.contains('leave')) {
      return Icons.favorite;
    }
    if (t.contains('vacation') ||
        t.contains('holiday') ||
        t.contains('paid time off')) {
      return Icons.redeem;
    }
    if (t.contains('transportation') ||
        t.contains('allowance') ||
        t.contains('travel')) {
      return Icons.location_on;
    }
    return Icons.check_circle_outline;
  }

  Widget _buildContentTab(
    String title,
    String content,
    ColorScheme colorScheme,
  ) {
    final points = content
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text(
          '$title:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              point,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final Widget _tabBar;

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
