import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/notifications/presentation/provider/notification_provider.dart';
import 'package:job_finder/features/recruiter/presentation/provider/company/company_profile_controller.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class HeaderSection extends ConsumerWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final recruiterState = ref.watch(companyProfileProvider);
    final notificationState = ref.watch(notificationControllerProvider);
    final company = recruiterState.company;
    final isLoading = recruiterState.isLoading && company == null;
    final unreadCount = notificationState.notifications
        .where((n) => !n.isRead)
        .length;

    return Row(
      children: [
        if (isLoading)
          const ShimmerCircle(radius: 24)
        else
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.05),
              ),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage:
                  (company?.logoUrl != null && company!.logoUrl.isNotEmpty)
                  ? NetworkImage(company.logoUrl)
                  : null,
              child: (company?.logoUrl == null || company!.logoUrl.isEmpty)
                  ? CircleAvatar(
                      radius: 26,
                      backgroundImage: AssetImage(
                        "assets/image/image_plaholder.jpg",
                      ),
                    )
                  : null,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading) ...[
                const ShimmerLoading(width: 40, height: 14),
                const SizedBox(height: 4),
                const ShimmerLoading(width: 120, height: 18),
              ] else ...[
                Text(
                  'Hello',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  company?.name ?? 'N/A',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push(AppPath.notifications),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(11),
                child: AppSvgIcon(
                  assetName: AppIcon.notification,
                  color: colorScheme.onSurface,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
