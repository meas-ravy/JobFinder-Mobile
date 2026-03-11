import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
import 'package:job_finder/core/provider/scroll_provider.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';

class ButonNavRecruiter extends HookConsumerWidget {
  final int? initialIndex;
  const ButonNavRecruiter({super.key, this.initialIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(initialIndex ?? 0);
    final pressedIndex = useState(-1);

    void animateTap(int index) {
      pressedIndex.value = index;
      Future.delayed(const Duration(milliseconds: 120), () {
        pressedIndex.value = -1;
      });
    }

    return Scaffold(
      body: IndexedStack(
        index: currentIndex.value,
        children: const [
          RecruiterHomePage(),
          RecruiterAppliedPage(),
          RecruiterStatsPage(),
          RecruiterMessagePage(),
          RecruiterProfilePage(),
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
          currentIndex: currentIndex.value,
          onTap: (index) {
            HapticFeedback.selectionClick();
            animateTap(index);
            if (currentIndex.value == index && index == 0) {
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
                      .read(recruiterControllerProvider.notifier)
                      .refreshAllJobs();
                }
              }
            } else {
              currentIndex.value = index;
            }
          },
          items: [
            BottomNavigationBarItem(
              label: AppLocalizations.of(context).homeLabel,
              icon: AnimatedScale(
                scale: pressedIndex.value == 0 ? 0.92 : 1,
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
                scale: pressedIndex.value == 0 ? 0.92 : 1,
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
                scale: pressedIndex.value == 1 ? 0.92 : 1,
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
                scale: pressedIndex.value == 1 ? 0.92 : 1,
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
                scale: pressedIndex.value == 2 ? 0.92 : 1,
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
                scale: pressedIndex.value == 2 ? 0.92 : 1,
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
                scale: pressedIndex.value == 3 ? 0.92 : 1,
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
                scale: pressedIndex.value == 3 ? 0.92 : 1,
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
                scale: pressedIndex.value == 4 ? 0.92 : 1,
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
                scale: pressedIndex.value == 4 ? 0.92 : 1,
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
