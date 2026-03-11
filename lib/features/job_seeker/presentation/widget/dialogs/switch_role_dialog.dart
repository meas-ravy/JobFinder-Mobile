import 'package:flutter/material.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class SwitchRoleDialog extends StatelessWidget {
  final String? avatarUrl;
  final String targetRole;
  final String title;
  final String content;

  const SwitchRoleDialog({
    super.key,
    this.avatarUrl,
    required this.targetRole,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSwitchingToRecruiter = targetRole == 'Recruiter';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Visual Indicator of Switching
            _buildRoleSwitchVisual(context, isDark, isSwitchingToRecruiter),
            const SizedBox(height: 24),

            // Content
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Switch Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSwitchVisual(
    BuildContext context,
    bool isDark,
    bool toRecruiter,
  ) {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Current Avatar (with actual image if available)
              _buildAvatar(
                context,
                avatarUrl, // Show current avatar here
                toRecruiter ? 'Seeker' : 'Recruiter',
                isDark,
              ),
              const SizedBox(width: 40),
              // Target Avatar (always placeholder to represent the 'target')
              _buildAvatar(
                context,
                null, // No URL for target, show generic role icon
                toRecruiter ? 'Recruiter' : 'Seeker',
                isDark,
                isTarget: true,
              ),
            ],
          ),
          // Arrow in between
          Positioned(
            child: Icon(
              Icons.arrow_forward_rounded,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    String? url,
    String roleType,
    bool isDark, {
    bool isTarget = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSeeker = roleType == 'Seeker';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 65,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            border: Border.all(
              color: isTarget
                  ? AppColor.primaryDark
                  : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
              width: 2,
            ),
            boxShadow: isTarget
                ? [
                    BoxShadow(
                      color: AppColor.primaryDark.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: ClipOval(
            child: (url != null && url.isNotEmpty)
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderIcon(isSeeker, isDark, colorScheme),
                  )
                : _buildPlaceholderIcon(isSeeker, isDark, colorScheme),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          roleType,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isTarget ? FontWeight.bold : FontWeight.w600,
            color: isTarget
                ? AppColor.primaryDark
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderIcon(
    bool isSeeker,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: AppSvgIcon(
        assetName: isSeeker ? AppIcon.profileBold : AppIcon.applicationBold,
        size: 32,
        color: isDark ? Colors.grey[400] : Colors.grey[500],
      ),
    );
  }
}
