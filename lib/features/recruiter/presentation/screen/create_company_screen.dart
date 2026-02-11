import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_finder/core/services/cloudinary_service.dart';
import 'package:job_finder/features/recruiter/data/models/company_model.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_state.dart';
import 'package:job_finder/features/recruiter/presentation/screen/post_job_steps/shared_widgets.dart';
import 'package:job_finder/shared/widget/loading_dialog.dart';

class CreateCompanyScreen extends HookConsumerWidget {
  const CreateCompanyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selectedImage = useState<File?>(null);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Create Company Profile',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    const FormFieldLabel(label: 'Company Logo'),
                    const SizedBox(height: 12),
                    _ImageUploadPicker(
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
                    if (selectedImage.value == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please upload a company logo'),
                        ),
                      );
                      return;
                    }

                    final values = formKey.currentState!.value;
                    LoadingDialog.show(context, message: 'Processing...');

                    try {
                      final logoUrl = await ref
                          .read(cloudinaryServiceProvider)
                          .uploadImage(selectedImage.value!, 'company-logo');

                      final company = CompanyModel(
                        name: values['name'],
                        contactEmail: values['contactEmail'],
                        contactPhone: values['contactPhone'],
                        location: values['location'],
                        description: values['description'],
                        logoUrl: logoUrl,
                      );

                      await ref
                          .read(recruiterControllerProvider.notifier)
                          .createCompany(company.toJson());

                      if (!context.mounted) return;
                      LoadingDialog.hide(context);

                      final recruiterState = ref.read(
                        recruiterControllerProvider,
                      );

                      if (recruiterState.errorMessage == null &&
                          recruiterState.lastAction ==
                              RecruiterAction.createCompany) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Company profile created successfully!',
                            ),
                          ),
                        );
                        context.pop();
                      } else {
                        final error = recruiterState.errorMessage;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error ?? 'Failed to create profile'),
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
                  'Create Profile',
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
  final File? selectedFile;
  final Function(File?) onPicked;

  const _ImageUploadPicker({
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
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.2),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Stack(
          children: [
            if (selectedFile == null)
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
                  if (selectedFile == null) ...[
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
                                Icons.check_circle_rounded,
                                color: Colors.green.shade400,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Logo Selected',
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
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () => onPicked(null),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Remove logo',
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
