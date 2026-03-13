import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/job_seeker_aplicat.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/job_seeker_home_page.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/job_seeker_mesage_page.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/job_seeker_profile_page.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/job_seeker_save_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_provider.dart';
import 'package:job_finder/l10n/app_localizations.dart';
import 'package:job_finder/shared/provider/scroll_provider.dart';

class MainWrapper extends ConsumerStatefulWidget {
  final int? initIndex;
  const MainWrapper({super.key, this.initIndex});

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapper();
}

class _MainWrapper extends ConsumerState<MainWrapper> {
  late PageController pageController;
  int presIndex = -1;

  @override
  void initState() {
    super.initState();
    // Use widget.initIndex if provided, otherwise default to current provider value
    final int initialIndex = widget.initIndex ?? ref.read(mainWrapperIndexProvider);
    pageController = PageController(initialPage: initialIndex);
    
    // Ensure the provider is synced with the initial index
    if (widget.initIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(mainWrapperIndexProvider.notifier).state = widget.initIndex!;
      });
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void animateTap(int index) {
    if (!mounted) return;
    setState(() {
      presIndex = index;
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() {
          presIndex = -1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainWrapperIndexProvider);

    // Listen to provider changes to sync PageView (e.g. when navigated via GoRouter)
    ref.listen(mainWrapperIndexProvider, (prev, next) {
      if (pageController.hasClients && pageController.page?.round() != next) {
        pageController.jumpToPage(next);
      }
    });

    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          JobSeekerHomePage(),
          JobSeekerSavePage(),
          JobSeekerAplicatPage(),
          JobSeekerMessagePage(),
          JobSeekerProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          iconSize: 22,
          currentIndex: currentIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            animateTap(index);
            if (currentIndex == index && index == 0) {
              final scrollController = ref.read(
                jobSeekerHomeScrollControllerProvider,
              );
              if (scrollController.hasClients) {
                if (scrollController.offset > 0) {
                  scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  ref.read(jobControllerProvider.notifier).fetchAll();
                }
              }
            } else {
              ref.read(mainWrapperIndexProvider.notifier).state = index;
              pageController.jumpToPage(index);
            }
          },

          items: [
            BottomNavigationBarItem(
              label: AppLocalizations.of(context).homeLabel,
              icon: AnimatedScale(
                scale: presIndex == 0 ? 0.92 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: SvgPicture.asset(
                  AppIcon.home,
                  width: 25,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              activeIcon: AnimatedScale(
                scale: presIndex == 0 ? 0.92 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: SvgPicture.asset(
                  AppIcon.homeBold,
                  width: 25,
                  colorFilter: const ColorFilter.mode(
                    AppColor.primaryDark,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            BottomNavigationBarItem(
              label: AppLocalizations.of(context).saveJobLabel,
              icon: AnimatedScale(
                scale: presIndex == 1 ? 0.92 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: SvgPicture.asset(
                  AppIcon.save,
                  width: 25,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              activeIcon: AnimatedScale(
                scale: presIndex == 1 ? 0.92 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: SvgPicture.asset(
                  AppIcon.saveBold,
                  width: 25,
                  colorFilter: const ColorFilter.mode(
                    AppColor.primaryDark,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            BottomNavigationBarItem(
              label: AppLocalizations.of(context).applicationLabel,
              icon: AnimatedScale(
                scale: presIndex == 2 ? 0.92 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: SvgPicture.asset(
                  AppIcon.application,
                  width: 25,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              activeIcon: AnimatedScale(
                scale: presIndex == 2 ? 0.92 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: SvgPicture.asset(
                  AppIcon.applicationBold,
                  width: 25,
                  colorFilter: const ColorFilter.mode(
                    AppColor.primaryDark,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            BottomNavigationBarItem(
              label: AppLocalizations.of(context).messageLabel,
              icon: AnimatedScale(
                scale: presIndex == 3 ? 0.92 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: SvgPicture.asset(
                  AppIcon.message,
                  width: 25,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              activeIcon: AnimatedScale(
                scale: presIndex == 3 ? 0.92 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: SvgPicture.asset(
                  AppIcon.messageBold,
                  width: 25,
                  colorFilter: const ColorFilter.mode(
                    AppColor.primaryDark,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            BottomNavigationBarItem(
              label: AppLocalizations.of(context).profileLabel,
              icon: AnimatedScale(
                scale: presIndex == 4 ? 0.92 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: SvgPicture.asset(
                  AppIcon.profile,
                  width: 25,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              activeIcon: AnimatedScale(
                scale: presIndex == 4 ? 0.92 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: SvgPicture.asset(
                  AppIcon.profileBold,
                  width: 25,
                  colorFilter: const ColorFilter.mode(
                    AppColor.primaryDark,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
