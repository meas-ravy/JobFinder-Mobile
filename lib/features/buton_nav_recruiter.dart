import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/recruiter/presentation/screen/recruiter_applied.dart';
import 'package:job_finder/features/recruiter/presentation/screen/recruiter_home.dart';
import 'package:job_finder/features/recruiter/presentation/screen/recruiter_message.dart';
import 'package:job_finder/features/recruiter/presentation/screen/recruiter_profile.dart';
import 'package:job_finder/features/recruiter/presentation/screen/recruiter_stats.dart';
import 'package:job_finder/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/core/provider/scroll_provider.dart';

class ButtonNavRecruit extends ConsumerStatefulWidget {
  final int? initIndex;
  const ButtonNavRecruit({super.key, this.initIndex});

  @override
  ConsumerState<ButtonNavRecruit> createState() => _ButtonNavRecruitState();
}

class _ButtonNavRecruitState extends ConsumerState<ButtonNavRecruit> {
  late int currentIndex;
  int presIndex = -1;
  late List<bool> activatedTabs;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initIndex ?? 0;
    // Pre-initialize only the current starting tab
    activatedTabs = List.generate(5, (index) => index == currentIndex);
  }

  void animatTap(int index) {
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
    const pages = [
      RecruiterHomePage(),
      RecruiterAppliedPage(),
      RecruiterStatsPage(),
      RecruiterMessagePage(),
      RecruiterProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: List.generate(pages.length, (index) {
          if (activatedTabs[index]) {
            return pages[index];
          } else {
            return const SizedBox.shrink();
          }
        }),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          iconSize: 22,
          currentIndex: currentIndex,
          onTap: (index) {
            animatTap(index);
            if (currentIndex == index && index == 0) {
              final scrollController = ref.read(
                recruiterHomeScrollControllerProvider,
              );
              if (scrollController.hasClients) {
                if (scrollController.offset > 0) {
                  scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  ref
                      .read(recruiterJobsControllerProvider.notifier)
                      .refreshAllJobs();
                }
              }
            } else {
              setState(() {
                currentIndex = index;
                // Activate the tab if it hasn't been yet
                if (!activatedTabs[index]) {
                  activatedTabs[index] = true;
                }
              });
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
                  AppIcon.homeStyleTwo,
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
                  AppIcon.homeStyleTwoBold,
                  width: 25,
                  colorFilter: const ColorFilter.mode(
                    AppColor.primaryDark,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            BottomNavigationBarItem(
              label: AppLocalizations.of(context).appliedLabel,
              icon: AnimatedScale(
                scale: presIndex == 1 ? 0.92 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: SvgPicture.asset(
                  AppIcon.documentBold,
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
                  AppIcon.document,
                  width: 25,
                  colorFilter: const ColorFilter.mode(
                    AppColor.primaryDark,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            BottomNavigationBarItem(
              label: AppLocalizations.of(context).statsLabel,
              icon: AnimatedScale(
                scale: presIndex == 2 ? 0.92 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: SvgPicture.asset(
                  AppIcon.chartBold,
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
                  AppIcon.chart,
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
