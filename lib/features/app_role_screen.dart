import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/shared/components/primary_button.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/enum/role.dart';
import 'package:job_finder/shared/widget/role_select_widget.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:job_finder/features/main_wrapper.dart';
import 'package:job_finder/features/recruiter/screen/recruiter_home.dart';

class AppRoleScreen extends HookWidget {
  const AppRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectRole = useState<UserRole?>(null);

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 75),
          logoSection(context),
          const SizedBox(height: 32),
          Container(height: 1.5, color: Colors.grey.withValues(alpha: 0.08)),
          const SizedBox(height: 45),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: RoleSelectWidget(
                    isSelected: selectRole.value == UserRole.jobSeeker,
                    title: 'Find a job',
                    subtitle: 'Find your dream job here',
                    icon: AppIcon.applicationBold,
                    iconColor: AppColor.findJob,
                    bagColor: Colors.blue,
                    onTap: () => selectRole.value = UserRole.jobSeeker,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: RoleSelectWidget(
                    isSelected: selectRole.value == UserRole.employer,
                    title: 'Find an Employee',
                    subtitle: 'I want to find employees.',
                    onTap: () => selectRole.value = UserRole.employer,
                    icon: AppIcon.profileBold,
                    iconColor: AppColor.findEmp,
                    bagColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
          Container(height: 1.5, color: Colors.grey.withValues(alpha: 0.08)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 56,
          child: PrimaryButton(
            label: 'Continue',
            onPressed: selectRole.value == null
                ? null
                : () {
                    if (selectRole.value == UserRole.jobSeeker) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MainWrapper()),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => RecruiterHome()),
                      );
                    }
                  },
          ),
        ),
      ),
    );
  }

  Widget logoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSvgIcon(assetName: AppIcon.appLogoTwo, size: 95),
          Text(
            'Jober',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 44,
              // ignore: deprecated_member_use
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 60),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose Your Job Type',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose whether you looking for job or you are organization need employees.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
