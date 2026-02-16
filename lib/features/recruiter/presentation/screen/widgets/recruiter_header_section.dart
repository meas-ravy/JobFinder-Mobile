import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';

class RecruiterHeaderSection extends ConsumerWidget {
  const RecruiterHeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final recruiterState = ref.watch(recruiterControllerProvider);
    final company = recruiterState.company;
    final isLoading = recruiterState.isLoading && company == null;

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
                  ? Text(
                      company?.name.characters.firstOrNull?.toUpperCase() ??
                          'R',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
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
                  company?.name ?? 'Recruiter',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
        FilledButton(
          onPressed: () {
            if (company == null) {
              _showProfileRestrictionDialog(context);
            } else {
              context.push(AppPath.postJob);
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: const StadiumBorder(),
          ),
          child: Text(
            'Post a Job',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _showProfileRestrictionDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Required'),
        content: Text(
          'Before you can post your first job, you need to set up your company profile. This helps candidates know who they are applying to!',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(AppPath.createCompany);
            },
            child: Text(
              'Set Up Profile',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
