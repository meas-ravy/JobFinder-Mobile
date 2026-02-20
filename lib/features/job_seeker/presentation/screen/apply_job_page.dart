import 'dart:ui';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:job_finder/core/services/cloudinary_service.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_provider.dart';
import 'package:dio/dio.dart';
import 'package:job_finder/core/helper/error_message.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ApplyJobPage extends HookConsumerWidget {
  final String jobId;

  const ApplyJobPage({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isUploading = useState(false);
    final isSubmitting = useState(false);
    final uploadedFileName = useState<String?>(null);
    final uploadedFileSize = useState<String?>(null);
    final resumeUrl = useState<String?>(null);
    final resumeError = useState<String?>(null);

    Future<void> pickAndUploadFile() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (result != null && result.files.single.path != null) {
          isUploading.value = true;
          final file = File(result.files.single.path!);
          uploadedFileName.value = result.files.single.name;

          // Size calculation
          final sizeInKb = (result.files.single.size / 1024).toStringAsFixed(1);
          uploadedFileSize.value = '$sizeInKb Kb';

          // Upload to Cloudinary following the specific 3-step instruction
          final url = await ref
              .read(cloudinaryServiceProvider)
              .uploadResume(file);
          resumeUrl.value = url;
          resumeError.value = null;
          isUploading.value = false;
        }
      } catch (e) {
        isUploading.value = false;
        if (context.mounted) {
          String message = 'Upload failed';
          if (e is DioException) {
            message = errorMessage(e.response?.statusCode ?? 500, e);
          } else {
            message = e.toString();
          }
          _showErrorDialog(context, message);
        }
      }
    }

    Future<void> handleSubmit() async {
      if (!(formKey.currentState?.saveAndValidate() ?? false)) return;

      if (resumeUrl.value == null) {
        resumeError.value = 'Please upload your CV';
        return;
      }

      final values = formKey.currentState!.value;
      isSubmitting.value = true;
      try {
        await ref
            .read(applyJobUseCaseProvider)
            .call(
              jobId: jobId,
              fullName: (values['fullName'] as String).trim(),
              email: (values['email'] as String).trim(),
              resumeUrl: resumeUrl.value!,
              coverLetter:
                  values['motivation']?.toString().trim().isNotEmpty == true
                  ? values['motivation'].toString().trim()
                  : null,
            );

        if (context.mounted) {
          // Success feedback
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Application Sent!'),
              content: const Text(
                'Your application has been submitted successfully. Good luck!',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          String message = 'Application failed';
          if (e is DioException) {
            message = errorMessage(e.response?.statusCode ?? 500, e);
          } else {
            message = e.toString();
          }
          _showErrorDialog(context, message);
        }
      } finally {
        isSubmitting.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
              size: 28,
            ),
          ),
        ),
        title: Text(
          'Apply Job',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FormBuilder(
        key: formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(context, 'Full Name', isDark),
                    const SizedBox(height: 12),
                    _buildTextField(
                      context,
                      'fullName',
                      'Full Name',
                      isDark,
                      validators: [FormBuilderValidators.required()],
                    ),
                    const SizedBox(height: 24),

                    _buildLabel(context, 'Email', isDark),
                    const SizedBox(height: 12),
                    _buildTextField(
                      context,
                      'email',
                      'Email',
                      isDark,
                      validators: [
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ],
                      suffixIcon: Icon(
                        Icons.mail_outline,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildLabel(context, 'Upload CV/Resume', isDark),
                    const SizedBox(height: 12),
                    _buildUploadSection(
                      context,
                      isDark,
                      isUploading.value,
                      uploadedFileName.value,
                      uploadedFileSize.value,
                      onUpload: pickAndUploadFile,
                      onRemove: () {
                        uploadedFileName.value = null;
                        uploadedFileSize.value = null;
                        resumeUrl.value = null;
                        resumeError.value = null;
                      },
                    ),
                    if (resumeError.value != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          resumeError.value!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    _buildLabel(
                      context,
                      'Motivation Letter (Optional)',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      context,
                      'motivation',
                      'Motivation letter...',
                      isDark,
                      maxLines: 6,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ElevatedButton(
                onPressed: (isSubmitting.value || isUploading.value)
                    ? null
                    : handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryDark,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: isSubmitting.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String name,
    String hint,
    bool isDark, {
    int maxLines = 1,
    Widget? suffixIcon,
    List<String? Function(String?)>? validators,
  }) {
    return FormBuilderTextField(
      name: name,
      maxLines: maxLines,
      validator: FormBuilderValidators.compose(validators ?? []),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white : Colors.black54),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? AppColor.cardDark : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColor.primaryDark, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildUploadSection(
    BuildContext context,
    bool isDark,
    bool isUploading,
    String? fileName,
    String? fileSize, {
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    if (isUploading) {
      return Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColor.cardDark : Colors.grey[50],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.blueAccent.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryDark),
            ),
            const SizedBox(height: 16),
            Text(
              'Uploading...',
              style: TextStyle(
                color: AppColor.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (fileName != null) {
      return Container(
        height: 80,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFFFEE2E2).withValues(alpha: 0.1)
              : const Color(0xFFFEF2F2).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              AppIcon.pdf,
              width: 48,
              height: 48,
              errorBuilder: (_, _, _) => const Icon(
                Icons.picture_as_pdf,
                size: 48,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileSize ?? '825 Kb',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, color: Colors.redAccent, size: 24),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onUpload,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          strokeWidth: 1.5,
          gap: 4,
          borderRadius: 24,
        ),
        child: Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColor.cardDark : Colors.grey[50],
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.file_upload_outlined,
                  color: AppColor.primaryDark,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Browse File',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.borderRadius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final Path dashedPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
          SizedBox(width: 12),
          Text('Application Error'),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text(
            'OK',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
