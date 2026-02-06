import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/shared/widget/scale_tap.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isFullWidth = true,
    this.height = 56,
    this.isLoading = false,
  });

  final String label;
  final void Function()? onPressed;
  final bool isFullWidth;
  final double height;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,

      child: ScaleTap(
        onTap: isLoading ? null : onPressed,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryLight,
            disabledBackgroundColor: AppColor.primaryLight,
            disabledForegroundColor: Colors.white,
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.2),
            shape: const StadiumBorder(),
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(label, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
