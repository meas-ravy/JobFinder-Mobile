import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/category_chip.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/featured_banner.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/home_header.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/job_seeker_card.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/search_bar_widget.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/section_header.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/profile_provider.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/tip_provider.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_provider.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/job_seeker_home_shimmer.dart';

class JobSeekerHomePage extends HookConsumerWidget {
  const JobSeekerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedCategory = useState('All');
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.profile;
    final tipState = ref.watch(tipControllerProvider);
    final jobState = ref.watch(jobControllerProvider);
    // Use a large initial page for seamless infinite scrolling
    const int initialPage = 5000;
    final pageController = usePageController(initialPage: initialPage);
    final currentPage = useState(initialPage);

    useEffect(() {
      if (!profileState.isLoading &&
          !profileState.isSetupShown &&
          (profile == null ||
              profile.fullName == null ||
              profile.fullName!.isEmpty)) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            ref.read(profileControllerProvider.notifier).markSetupShown();
            context.go(AppPath.setupProfile);
          }
        });
      }
      return null;
    }, [profileState.isLoading, profileState.isSetupShown, profile]);

    useEffect(() {
      if (tipState.tips.length <= 1) return null;

      final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (pageController.hasClients) {
          pageController.nextPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });

      return timer.cancel;
    }, [tipState.tips, pageController]);

    // this run every time when widget build with depency []
    // useEffect(() {
    //   Future.microtask(() {
    //     ref.read(profileControllerProvider.notifier).fetchProfile();
    //   });
    //   return null;
    // }, []);

    final categories = [
      'All',
      'Technology',
      'Marketing',
      'Sales',
      'Engineering',
      'Design',
      'Healthcare',
      'Finance',
      'Education',
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

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(profileControllerProvider.notifier).fetchProfile(),
              ref.read(tipControllerProvider.notifier).fetchTips(),
              ref.read(jobControllerProvider.notifier).fetchAll(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // 1. Header
              SliverToBoxAdapter(
                child: HomeHeader(
                  userName: profile?.fullName ?? 'User',
                  userAvatarUrl: profile?.avatarUrl,
                  hasUnreadNotifications: true,
                  isLoading: profileState.isLoading,
                  onNotificationTap: () {},
                ),
              ),

              // 2. Search Bar
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () => context.push(AppPath.search),
                  child: AbsorbPointer(
                    child: SearchBarWidget(
                      onSearch: (value) {},
                      onFilterTap: () {},
                    ),
                  ),
                ),
              ),

              // 3. Featured Banner
              SliverToBoxAdapter(
                child: tipState.isLoading
                    ? HomeBannerShimmer(isDark: isDark)
                    : tipState.tips.isEmpty
                    ? FeaturedBanner(
                        title: 'See how you can',
                        buttonText: 'Read more',
                        imageUrl:
                            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&h=200&fit=crop',
                        onButtonPressed: () {},
                      )
                    : Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          SizedBox(
                            height: 204,
                            child: tipState.tips.length > 1
                                ? PageView.builder(
                                    controller: pageController,
                                    onPageChanged: (index) =>
                                        currentPage.value = index,
                                    itemCount: 10000,
                                    itemBuilder: (context, index) {
                                      final tip = tipState
                                          .tips[index % tipState.tips.length];
                                      return FeaturedBanner(
                                        title: tip.title ?? '',
                                        buttonText: 'Read more',
                                        imageUrl: tip.imageUrl,
                                        onButtonPressed: () {
                                          context.push(
                                            AppPath.tipDetail,
                                            extra: tip.id,
                                          );
                                        },
                                      );
                                    },
                                  )
                                : FeaturedBanner(
                                    title: tipState.tips.first.title ?? '',
                                    buttonText: 'Read more',
                                    imageUrl: tipState.tips.first.imageUrl,
                                    onButtonPressed: () {
                                      context.push(
                                        AppPath.tipDetail,
                                        extra: tipState.tips.first.id,
                                      );
                                    },
                                  ),
                          ),
                          if (tipState.tips.length > 1)
                            Positioned(
                              bottom: 38,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(tipState.tips.length, (
                                  index,
                                ) {
                                  final isActive =
                                      (currentPage.value %
                                          tipState.tips.length) ==
                                      index;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: isActive ? 20 : 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.white.withValues(
                                        alpha: isActive ? 0.9 : 0.4,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),
              ),

              // 4. Recommendation Section
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Recommendation',
                  onSeeAllTap: () => context.push(AppPath.seeAllRecommended),
                ),
              ),

              // 5. Horizontal Recommendations
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: jobState.isLoading
                      ? RecommendedJobShimmer(isDark: isDark)
                      : jobState.recommendedJobs.isEmpty
                      ? const Center(child: Text('No recommendations found'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: jobState.recommendedJobs.length,
                          itemBuilder: (context, index) {
                            final job = jobState.recommendedJobs[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right:
                                    index < jobState.recommendedJobs.length - 1
                                    ? 16
                                    : 0,
                                bottom: 4,
                              ),
                              child: SizedBox(
                                width: 360,
                                child: JobSeekerCard(job: job),
                              ),
                            );
                          },
                        ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 6. Recent Jobs Section
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Recent Jobs',
                  onSeeAllTap: () => context.push(AppPath.seeAllRecent),
                ),
              ),

              // 7. Category Filters
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: CategoryChip(
                          label: categories[index],
                          isSelected:
                              selectedCategory.value == categories[index],
                          onTap: () {
                            if (selectedCategory.value != categories[index]) {
                              selectedCategory.value = categories[index];
                              ref
                                  .read(jobControllerProvider.notifier)
                                  .fetchRecentJobs(category: categories[index]);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // 8. Recent Jobs List (Vertical)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: jobState.isRecentLoading
                    ? SliverToBoxAdapter(
                        child: RecentJobShimmer(isDark: isDark),
                      )
                    : jobState.recentJobs.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text('No recent jobs in this category'),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final job = jobState.recentJobs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: JobSeekerCard(job: job, isHorizontal: true),
                          );
                        }, childCount: jobState.recentJobs.length),
                      ),
              ),

              // Padding for bottom nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
