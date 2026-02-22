import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/tip_provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class TipDetailScreen extends HookConsumerWidget {
  final String tipId;
  const TipDetailScreen({super.key, required this.tipId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipState = ref.watch(tipControllerProvider);
    final tip = tipState.currentTip;
    final colorScheme = Theme.of(context).colorScheme;

    useEffect(() {
      Future.microtask(() {
        if (context.mounted) {
          ref.read(tipControllerProvider.notifier).fetchTipDetail(tipId);
        }
      });
      return null;
    }, [tipId]);

    if (tipState.isLoading) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final baseColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
      final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

      return Scaffold(
        appBar: AppBar(title: const Text("Tips Detail")),
        body: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 120,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 100,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 200,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 32),
                  ...List.generate(
                    12,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: index == 11 ? 200 : double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (tipState.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(tipState.errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(tipControllerProvider.notifier)
                      .fetchTipDetail(tipId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (tip == null) {
      return const Scaffold(body: Center(child: Text('Tip not found')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Tips Detail")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primaryDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Category: ${tip.category}',
                      style: const TextStyle(
                        color: AppColor.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    tip.createdAt != null
                        ? DateFormat(
                            'dd MMM yyyy',
                          ).format(DateTime.parse(tip.createdAt!))
                        : '',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              Text(
                tip.title ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              Divider(height: 32, color: colorScheme.surfaceContainerHighest),
              Text(
                tip.content ?? '',
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
