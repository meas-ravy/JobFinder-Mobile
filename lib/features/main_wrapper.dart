import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/screen/job_seeker_aplicat.dart';
import 'package:job_finder/features/job_seeker/screen/job_seeker_home_page.dart';
import 'package:job_finder/features/job_seeker/screen/job_seeker_mesage_page.dart';
import 'package:job_finder/features/job_seeker/screen/job_seeker_profile_page.dart';
import 'package:job_finder/features/job_seeker/screen/job_seeker_save_page.dart';

class MainWrapper extends HookWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(0);
    final pressedIndex = useState(-1);

    void animateTap(int index) {
      pressedIndex.value = index;
      Future.delayed(const Duration(milliseconds: 120), () {
        pressedIndex.value = -1;
      });
    }

    Widget buildBody() {
      switch (currentIndex.value) {
        case 0:
          return JobSeekerHomePage();
        case 1:
          return JobSeekerSavePage();
        case 2:
          return JobSeekerAplicatPage();
        case 3:
          return JobSeekerMessagePage();
        case 4:
          return JobSeekerProfilePage();
        default:
          return JobSeekerHomePage();
      }
    }

    return Scaffold(
      body: buildBody(),
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
            currentIndex.value = index;
          },
          items: [
            BottomNavigationBarItem(
              label: "Home",
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
              label: "Save Job",
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
              label: "Application",
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
              label: "Message",
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
              label: "Profile",
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
