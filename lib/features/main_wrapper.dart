import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
import 'package:job_finder/core/provider/scroll_provider.dart';

class MainWrapper extends HookConsumerWidget {
  final int? initialIndex;
  const MainWrapper({super.key, this.initialIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainWrapperIndexProvider);
    final pressedIndex = useState(-1);

    void animateTap(int index) {
      pressedIndex.value = index;
      Future.delayed(const Duration(milliseconds: 120), () {
        pressedIndex.value = -1;
      });
    }

    useEffect(() {
      if (initialIndex != null) {
        Future.microtask(() {
          ref.read(mainWrapperIndexProvider.notifier).state = initialIndex!;
        });
      }
      return null;
    }, [initialIndex]);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
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
                  AppIcon.home,
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
                scale: pressedIndex.value == 1 ? 0.92 : 1,
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
                scale: pressedIndex.value == 1 ? 0.92 : 1,
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
                scale: pressedIndex.value == 2 ? 0.92 : 1,
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
                scale: pressedIndex.value == 2 ? 0.92 : 1,
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
