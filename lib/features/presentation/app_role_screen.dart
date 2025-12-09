import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:job_finder/core/components/primary_button.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/enum/role.dart';
import 'package:job_finder/core/widget/role_select_widget.dart';
import 'package:job_finder/core/widget/svg_icon.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:job_finder/features/presentation/main_wrapper.dart';
import 'package:job_finder/features/presentation/recruiter/screen/recruiter_home.dart';

class AppRoleScreen extends HookWidget {
  const AppRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectRole = useState<UserRole?>(null);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 75),
              logoSection(context),
              const SizedBox(height: 32),
              Container(
                height: 1.5,
                color: Colors.grey.withValues(alpha: 0.08),
              ),
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
                        icon: Iconsax.briefcase,
                        color: Colors.blue,
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
                        icon: Iconsax.user,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 45),
              Container(
                height: 1.5,
                color: Colors.grey.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 45),
            ],
          ),
        ),
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
          AppSvgIcon(assetName: Assets.appLogo, size: 120),

          const SizedBox(height: 60),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Your Role',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'select the role which suite you need',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
