import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/features/notifications/data/models/notification_model.dart';
import 'package:job_finder/features/notifications/presentation/provider/notification_provider.dart';
import 'package:job_finder/core/services/notification_service.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class NotificationScreen extends HookConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    useEffect(() {
      Future.microtask(() {
        if (context.mounted) {
          ref.read(notificationControllerProvider.notifier).getNotifications();
        }
      });
      return null;
    }, []);

    Map<String, List<NotificationModel>> groupNotifications(
      List<NotificationModel> notifications,
    ) {
      final groups = <String, List<NotificationModel>>{};
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      for (final notification in notifications) {
        final date = DateTime(
          notification.createdAt.year,
          notification.createdAt.month,
          notification.createdAt.day,
        );
        String groupKey;
        if (date == today) {
          groupKey = 'Today';
        } else if (date == yesterday) {
          groupKey = 'Yesterday';
        } else {
          groupKey = DateFormat('dd MMM, yyyy').format(date);
        }

        if (!groups.containsKey(groupKey)) {
          groups[groupKey] = [];
        }
        groups[groupKey]!.add(notification);
      }
      return groups;
    }

    final groupedNotifications = groupNotifications(state.notifications);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          if (state.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                // Future: Implement mark all as read API
                for (final n in state.notifications.where((n) => !n.isRead)) {
                  ref
                      .read(notificationControllerProvider.notifier)
                      .markAsRead(n.id);
                }
              },
              child: const Text('Mark all as read'),
            ),
          const SizedBox(width: 8),
        ],
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: state.isLoading && state.notifications.isEmpty
          ? const _NotificationShimmer()
          : state.notifications.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(notificationControllerProvider.notifier)
                  .getNotifications(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: groupedNotifications.length,
                itemBuilder: (context, index) {
                  final groupKey = groupedNotifications.keys.elementAt(index);
                  final groupItems = groupedNotifications[groupKey]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          groupKey,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...groupItems.map(
                        (notification) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _NotificationCard(notification: notification),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Keep Up to Date',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Your notifications will be listed here once you receive them.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                // Refresh logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isRead = notification.isRead;

    return InkWell(
      onTap: () async {
        if (!isRead) {
          ref
              .read(notificationControllerProvider.notifier)
              .markAsRead(notification.id);
        }

        if (notification.link != null && notification.link!.isNotEmpty) {
          NotificationService.instance.handleLink(notification.link!);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? colorScheme.surface : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRead
                ? colorScheme.outlineVariant.withValues(alpha: 0.2)
                : colorScheme.primary.withValues(alpha: 0.2),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: [
            if (!isRead)
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.imageUrl != null &&
                notification.imageUrl!.isNotEmpty)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(notification.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isRead
                      ? colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        )
                      : colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AppSvgIcon(
                  assetName: AppIcon.notification,
                  size: 24,
                  color: isRead
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.primary,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: isRead
                                ? colorScheme.onSurface
                                : colorScheme.onSurface,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.content,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      height: 1.4,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: isRead ? 0.7 : 0.9,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'hh:mm a',
                          Localizations.localeOf(context).languageCode,
                        ).format(notification.createdAt),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationShimmer extends StatelessWidget {
  const _NotificationShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerCircle(radius: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLoading(width: 150, height: 16),
                    const SizedBox(height: 8),
                    const ShimmerLoading(width: double.infinity, height: 12),
                    const SizedBox(height: 4),
                    const ShimmerLoading(width: 200, height: 12),
                    const SizedBox(height: 12),
                    const ShimmerLoading(width: 80, height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
