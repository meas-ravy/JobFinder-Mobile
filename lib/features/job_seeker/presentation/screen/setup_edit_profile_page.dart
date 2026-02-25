import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/services/cloudinary_service.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/profile_provider.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class EditProfilePage extends HookConsumerWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.profile;
    final colorScheme = Theme.of(context).colorScheme;

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: profile?.fullName);
    final emailController = useTextEditingController(text: profile?.email);
    final dobController = useTextEditingController(
      text: profile?.dateOfBirth != null
          ? DateFormat(
              'dd-MM-yyyy',
            ).format(DateTime.parse(profile!.dateOfBirth!))
          : null,
    );
    final gender = useState<String?>(profile?.gender ?? 'Male');
    final selectedImage = useState<File?>(null);
    final isUploading = useState(false);

    // Sync controllers when profile data loads asynchronously
    useEffect(() {
      if (profile != null) {
        if (nameController.text.isEmpty && profile.fullName != null) {
          nameController.text = profile.fullName!;
        }
        if (emailController.text.isEmpty && profile.email != null) {
          emailController.text = profile.email!;
        }
        if (dobController.text.isEmpty && profile.dateOfBirth != null) {
          dobController.text = DateFormat(
            'dd-MM-yyyy',
          ).format(DateTime.parse(profile.dateOfBirth!));
        }
        if (profile.gender != null) {
          // Normalize gender to match dropdown items
          final normalizedGender =
              profile.gender!.substring(0, 1).toUpperCase() +
              profile.gender!.substring(1).toLowerCase();
          if (['Male', 'Female', 'Other'].contains(normalizedGender)) {
            gender.value = normalizedGender;
          }
        }
      }
      return null;
    }, [profile]);

    final picker = useMemoized(() => ImagePicker());

    Future<void> pickImage() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    }

    final isSetup =
        GoRouterState.of(context).uri.toString() == AppPath.setupProfile ||
        (profile == null ||
            profile.fullName == null ||
            profile.fullName!.isEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSetup ? 'Complete Your Profile' : 'Edit Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(isSetup ? Icons.close : Icons.arrow_back, size: 26),
          onPressed: () {
            if (isSetup) {
              context.go(AppPath.jobSeekerHome);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      backgroundImage: selectedImage.value != null
                          ? FileImage(selectedImage.value!)
                          : (profile?.avatarUrl != null
                                    ? NetworkImage(profile!.avatarUrl!)
                                    : null)
                                as ImageProvider?,
                      child:
                          selectedImage.value == null &&
                              profile?.avatarUrl == null
                          ? const AppSvgIcon(
                              assetName: AppIcon.profileBold,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColor.primaryDark,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surfaceContainerHighest,
                              width: 2,
                            ),
                          ),
                          child: const AppSvgIcon(
                            assetName: AppIcon.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              _buildTextField(
                colorScheme: colorScheme,
                label: 'Full Name',
                controller: nameController,
                hint: 'Enter your full name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                colorScheme: colorScheme,
                label: 'Email',
                controller: emailController,
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildDatePickerField(
                colorScheme: colorScheme,
                context: context,
                label: 'Date of Birth',
                controller: dobController,
              ),
              const SizedBox(height: 20),
              _buildGenderDropdown(
                colorScheme: colorScheme,
                label: 'Gender',
                value: gender.value,
                onChanged: (val) => gender.value = val,
              ),
              const SizedBox(height: 48),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (profileState.isLoading || isUploading.value)
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() != true) return;

                          String? avatarUrl = profile?.avatarUrl;

                          if (selectedImage.value != null) {
                            isUploading.value = true;
                            try {
                              avatarUrl = await ref
                                  .read(cloudinaryServiceProvider)
                                  .uploadImage(
                                    selectedImage.value!,
                                    'job-seeker-avatar',
                                  );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Image upload failed: ${e.toString()}',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              isUploading.value = false;
                              return;
                            }
                            isUploading.value = false;
                          }

                          final profileController = ref.read(
                            profileControllerProvider.notifier,
                          );
                          final profileData = {
                            'fullName': nameController.text,
                            if (emailController.text.isNotEmpty &&
                                emailController.text != profile?.email)
                              'email': emailController.text,
                            'dateOfBirth': dobController.text.isNotEmpty
                                ? DateFormat('yyyy-MM-dd').format(
                                    DateFormat(
                                      'dd-MM-yyyy',
                                    ).parse(dobController.text),
                                  )
                                : null,
                            'gender': gender.value,
                            if (avatarUrl != null) 'avatarUrl': avatarUrl,
                          };

                          final success = isSetup
                              ? await profileController.createProfile(
                                  profileData,
                                )
                              : await profileController.updateProfile(
                                  profileData,
                                );
                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile saved successfully!'),
                                ),
                              );
                              if (isSetup) {
                                context.go(AppPath.jobSeekerHome);
                              } else {
                                context.pop();
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    profileState.errorMessage ??
                                        'Failed to save profile',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: (profileState.isLoading || isUploading.value)
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isSetup ? 'Save' : 'Save Changes',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (isSetup) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go(AppPath.jobSeekerHome),
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.surfaceContainerHighest,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.surfaceContainerHighest,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.primaryDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              controller.text = DateFormat('dd-MM-yyyy').format(date);
            }
          },
          decoration: InputDecoration(
            hintText: 'Select Date',
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.surfaceContainerHighest,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.surfaceContainerHighest,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.primaryDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown({
    required String label,
    required String? value,
    required ColorScheme colorScheme,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: [
            'Male',
            'Female',
            'Other',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.surfaceContainerHighest,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.surfaceContainerHighest,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.primaryDark),
            ),
          ),
        ),
      ],
    );
  }
}
