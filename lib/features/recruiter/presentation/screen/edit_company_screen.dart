import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/services/cloudinary_service.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_state.dart';
import 'package:job_finder/features/recruiter/presentation/screen/post_job_steps/shared_widgets.dart';
import 'package:job_finder/shared/widget/loading_dialog.dart';

import 'package:job_finder/shared/widget/shimmer_loading.dart';

class EditCompanyScreen extends HookConsumerWidget {
  const EditCompanyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final recruiterState = ref.watch(recruiterControllerProvider);
    final company = recruiterState.company;

    final selectedImage = useState<File?>(null);

    // If company is null, check if loading or show error
    if (company == null) {
      if (recruiterState.isLoading) {
        return const Scaffold(body: _EditShimmer());
      }
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Company profile not found')),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Edit Company Profile',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: FormBuilder(
                key: formKey,
                initialValue: {
                  'name': company.name,
                  'contactEmail': company.contactEmail,
                  'contactPhone': company.contactPhone,
                  'location': company.location,
                  'description': company.description,
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    const FormFieldLabel(label: 'Company Logo'),
                    const SizedBox(height: 12),
                    _ImageUploadPicker(
                      networkUrl: company.logoUrl,
                      selectedFile: selectedImage.value,
                      onPicked: (file) => selectedImage.value = file,
                    ),
                    const SizedBox(height: 20),
                    const FormFieldLabel(label: 'Company Name'),
                    const SizedBox(height: 8),
                    FormTextInput(
                      name: 'name',
                      hint: 'Tech Solutions Inc.',
                      validators: [FormBuilderValidators.required()],
                    ),
                    const SizedBox(height: 20),

                    const FormFieldLabel(label: 'Contact Email'),
                    const SizedBox(height: 8),
                    FormTextInput(
                      name: 'contactEmail',
                      hint: 'hr@company.com',
                      keyboardType: TextInputType.emailAddress,
                      validators: [
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const FormFieldLabel(label: 'Contact Phone'),
                    const SizedBox(height: 8),
                    FormTextInput(
                      name: 'contactPhone',
                      hint: '+855 12 345 678',
                      keyboardType: TextInputType.phone,
                      validators: [FormBuilderValidators.required()],
                    ),
                    const SizedBox(height: 20),

                    const FormFieldLabel(label: 'Location'),
                    const SizedBox(height: 8),
                    FormDropdownInput(
                      name: 'location',
                      hint: 'Select district',
                      items: const [
                        'Chamkar Mon, phnom penh',
                        'Daun Penh, phnom penh',
                        'Prampir Meakkakra, phnom penh',
                        'Tuol Kork, phnom penh',
                        'Dangkao, phnom penh',
                        'Meanchey, phnom penh',
                        'Russey Keo, phnom penh',
                        'Sen Sok, phnom penh',
                        'Pou Senchey, phnom penh',
                        'Chroy Changvar, phnom penh',
                        'Prek Pnov, phnom penh',
                        'Chbar Ampov, phnom penh',
                        'Boeng Keng Kang, phnom penh',
                        'Kamboul, phnom penh',
                      ],
                      validators: [FormBuilderValidators.required()],
                    ),
                    const SizedBox(height: 20),

                    const FormFieldLabel(label: 'Description'),
                    const SizedBox(height: 8),
                    FormTextInput(
                      name: 'description',
                      hint: 'Tell candidates about your company...',
                      maxLines: 5,
                      validators: [
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(50),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () async {
                  if (formKey.currentState?.saveAndValidate() ?? false) {
                    final values = DataMap.from(formKey.currentState!.value);
                    LoadingDialog.show(context, message: 'Updating profile...');

                    try {
                      // If new image selected, upload it
                      if (selectedImage.value != null) {
                        final logoUrl = await ref
                            .read(cloudinaryServiceProvider)
                            .uploadImage(selectedImage.value!, 'company-logo');
                        values['logoUrl'] = logoUrl;
                      }

                      await ref
                          .read(recruiterControllerProvider.notifier)
                          .updateCompany(values);

                      if (!context.mounted) return;
                      LoadingDialog.hide(context);

                      final updatedState = ref.read(
                        recruiterControllerProvider,
                      );

                      if (updatedState.errorMessage == null &&
                          updatedState.lastAction ==
                              RecruiterAction.updateCompany) {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     content: Text(
                        //       'Company profile updated successfully!',
                        //     ),
                        //   ),
                        // );
                        context.pop();
                      } else {
                        final error = updatedState.errorMessage;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error ?? 'Failed to update profile'),
                            backgroundColor: colorScheme.error,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        LoadingDialog.hide(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: colorScheme.error,
                          ),
                        );
                      }
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageUploadPicker extends StatelessWidget {
  final String? networkUrl;
  final File? selectedFile;
  final Function(File?) onPicked;

  const _ImageUploadPicker({
    this.networkUrl,
    required this.selectedFile,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );
        if (image != null) {
          onPicked(File(image.path));
        }
      },
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          image: selectedFile != null
              ? DecorationImage(
                  image: FileImage(selectedFile!),
                  fit: BoxFit.cover,
                )
              : (networkUrl != null && networkUrl!.isNotEmpty)
              ? DecorationImage(
                  image: NetworkImage(networkUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            if (selectedFile == null &&
                (networkUrl == null || networkUrl!.isEmpty))
              CustomPaint(
                size: const Size(double.infinity, 160),
                painter: DashedRectPainter(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  strokeWidth: 1,
                  gap: 4,
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selectedFile == null &&
                      (networkUrl == null || networkUrl!.isEmpty)) ...[
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to upload company logo',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                selectedFile != null
                                    ? Icons.check_circle_rounded
                                    : Icons.image,
                                color: selectedFile != null
                                    ? Colors.green.shade400
                                    : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedFile != null
                                    ? 'New Logo Selected'
                                    : 'Current Logo',
                                style: textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Change',
                                style: textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditShimmer extends StatelessWidget {
  const _EditShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const ShimmerLoading(width: 120, height: 20),
          const SizedBox(height: 12),
          const ShimmerLoading(
            width: double.infinity,
            height: 160,
            borderRadius: 20,
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < 4; i++) ...[
            const ShimmerLoading(width: 120, height: 20),
            const SizedBox(height: 8),
            const ShimmerLoading(
              width: double.infinity,
              height: 56,
              borderRadius: 16,
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
