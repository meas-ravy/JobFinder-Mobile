import 'package:flutter/material.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class SocialIconButton extends StatelessWidget {
  const SocialIconButton({
    super.key,
    required this.assetName,
    required this.onTap,
    required this.backgroundColor,
  });

  final String assetName;
  final VoidCallback onTap;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        height: 52,
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          // border: Border.all(
          //   color: colorScheme.onSurface.withValues(alpha: 0.10),
          // ),
        ),
        child: Center(child: AppSvgIcon(assetName: assetName, size: 28)),
      ),
    );
  }
}
