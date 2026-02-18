import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';

class FilterContentCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final Widget child;
  final bool isExpanded;
  final VoidCallback onToggle;

  const FilterContentCard({
    super.key,
    required this.isDark,
    required this.title,
    required this.child,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColor.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1.2,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Toggle)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColor.primaryDark,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Content
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}
