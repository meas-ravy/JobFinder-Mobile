import 'package:flutter/material.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/ai_assistant_provider.dart';

class HomeHeader extends ConsumerWidget {
  final String userName;
  final String? userAvatarUrl;
  final VoidCallback? onNotificationTap;
  final int unreadNotificationCount;
  final bool isLoading;

  const HomeHeader({
    super.key,
    required this.userName,
    this.userAvatarUrl,
    this.onNotificationTap,
    this.unreadNotificationCount = 0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final healthScore = ref.watch(cvHealthScoreProvider);

    final hour = DateTime.now().hour;
    String greeting;
    String emoji;

    if (hour >= 5 && hour < 12) {
      greeting = 'Good Morning';
      emoji = '👋';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
      emoji = '☀️';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good Evening';
      emoji = '🌆';
    } else {
      greeting = 'Good Night';
      emoji = '🌙';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          // Profile Avatar with AI Match Ring
          isLoading
              ? const ShimmerCircle(radius: 25)
              : Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // AI Health Score Ring (Mini)
                    SizedBox(
                      width: 62,
                      height: 62,
                      child: CircularProgressIndicator(
                        value: (healthScore ?? 0) / 100,
                        strokeWidth: 3,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          healthScore == null
                              ? theme.primaryColor.withValues(alpha: 0.2)
                              : (healthScore > 70
                                    ? Colors.green
                                    : Colors.orange),
                        ),
                      ),
                    ),
                    // Main Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: userAvatarUrl != null && userAvatarUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                userAvatarUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: AppSvgIcon(
                                assetName: AppIcon.profileBold,
                                size: 24,
                                color: theme.primaryColor,
                              ),
                            ),
                    ),
                    // mini percentage/badge
                    if (healthScore != null)
                      Positioned(
                        bottom: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (healthScore > 70
                                ? Colors.green
                                : Colors.orange),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '$healthScore%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
          const SizedBox(width: 12),
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      greeting,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(emoji, style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 2),
                isLoading
                    ? const ShimmerLoading(width: 120, height: 20)
                    : Text(
                        userName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
              ],
            ),
          ),
          // Notification Icon
          InkWell(
            onTap: onNotificationTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: AppSvgIcon(
                      assetName: AppIcon.notification,
                      color: isDark ? Colors.white : Colors.black,
                      size: 24,
                    ),
                  ),
                  if (unreadNotificationCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            unreadNotificationCount > 99
                                ? '99+'
                                : unreadNotificationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
