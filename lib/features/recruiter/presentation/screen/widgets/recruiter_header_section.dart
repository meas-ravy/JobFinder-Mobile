import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
      ],
    );
  }
}
