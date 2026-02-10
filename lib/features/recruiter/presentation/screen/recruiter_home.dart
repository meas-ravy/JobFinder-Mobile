import 'package:flutter/material.dart';
import 'package:job_finder/features/onboarding_screen.dart';
import 'package:job_finder/l10n/app_localizations.dart';

class RecruiterHomePage extends StatelessWidget {
  const RecruiterHomePage({super.key});

  static const List<JobCardData> _jobs = [
    JobCardData(
      title: 'Product Designer',
      company: 'Slack',
      location: 'New York',
      time: '5 hours ago',
      logo: 'https://cdn-icons-png.flaticon.com/512/3800/3800024.png',
      description: 'We are looking for a dynamic Product designer...',
    ),
    JobCardData(
      title: 'UI UX Designer',
      company: 'Webmoney',
      location: 'New York',
      time: '5 hours ago',
      logo: 'https://cdn-icons-png.flaticon.com/512/888/888871.png',
      description: 'We are looking for a dynamic Product designer...',
    ),
    JobCardData(
      title: 'Marketing Manager',
      company: 'Opera',
      location: 'New York',
      time: '5 hours ago',
      logo: 'https://cdn-icons-png.flaticon.com/512/732/732233.png',
      description: 'We are looking for a dynamic Product designer...',
    ),
    JobCardData(
      title: 'Graphic Design',
      company: 'Swift',
      location: 'New York',
      time: '5 hours ago',
      logo: 'https://cdn-icons-png.flaticon.com/512/5968/5968363.png',
      description: 'We are looking for a dynamic Product designer...',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // final primaryGreen = const Color(0xff22D38A);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 80,
          title: const _HeaderSection(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Column(
              children: [
                TabBar(
                  dividerColor: colorScheme.outlineVariant.withValues(
                    alpha: 0.2,
                  ),
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

        body: TabBarView(
          children: [
            _buildJobsList(),
            const Center(child: Text('Upcoming Jobs')),
            const Center(child: Text('Previous Jobs')),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _jobs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return JobCard(data: _jobs[index]);
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
            'https://api.uifaces.co/our-content/donated/x4_8P_NS.jpg',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hello',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Savannah Nguyen',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: StadiumBorder(),
          ),
          child: Text(
            'Post a Job',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.data});

  final JobCardData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Image.network(data.logo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.company} . ${data.location} | ${data.time}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: colorScheme.onSurfaceVariant,
                  size: 28,
                ),
                onSelected: (value) {
                  // Handle menu selection
                },
                itemBuilder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          const Icon(Icons.people_outline, size: 20),
                          const SizedBox(width: 12),
                          Text(l10n.viewApplications),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 20),
                          const SizedBox(width: 12),
                          Text(l10n.editJob),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.deleteJob,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              data.description,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JobCardData {
  const JobCardData({
    required this.title,
    required this.company,
    required this.location,
    required this.time,
    required this.logo,
    required this.description,
  });

  final String title;
  final String company;
  final String location;
  final String time;
  final String logo;
  final String description;
}
