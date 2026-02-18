import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/filter/filter_components.dart';

class LocationSalaryCard extends StatelessWidget {
  final bool isDark;
  final ColorScheme colorScheme;
  final ValueNotifier<String?> location;
  final ValueNotifier<RangeValues> salaryRange;
  final ValueNotifier<String> salaryPeriod;
  final bool isExpanded;
  final VoidCallback onToggle;

  const LocationSalaryCard({
    super.key,
    required this.isDark,
    required this.colorScheme,
    required this.location,
    required this.salaryRange,
    required this.salaryPeriod,
    required this.isExpanded,
    required this.onToggle,
  });

  String _formatSalary(double value) {
    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k';
    }
    return '\$${value.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  const Text(
                    'Location & Salary',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location field with pin icon
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[900]
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      onChanged: (v) => location.value = v.isEmpty ? null : v,
                      controller: TextEditingController(text: location.value),
                      decoration: InputDecoration(
                        hintText: 'Enter location',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Salary range badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SalaryBadge(
                        label: _formatSalary(salaryRange.value.start),
                      ),
                      SalaryBadge(label: _formatSalary(salaryRange.value.end)),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Range slider
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColor.primaryDark,
                      inactiveTrackColor: isDark
                          ? Colors.grey[800]
                          : Colors.grey[300],
                      thumbColor: Colors.white,
                      overlayColor: AppColor.primaryDark.withValues(alpha: 0.1),
                      trackHeight: 3,
                      rangeThumbShape: CustomRangeThumbShape(),
                    ),
                    child: RangeSlider(
                      values: salaryRange.value,
                      min: 0,
                      max: 20000,
                      divisions: 40,
                      onChanged: (values) => salaryRange.value = values,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Period dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[900]
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: salaryPeriod.value,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        dropdownColor: isDark
                            ? AppColor.cardDark
                            : Colors.white,
                        items: ['per month', 'per year', 'per hour']
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) salaryPeriod.value = val;
                        },
                      ),
                    ),
                  ),
                ],
              ),
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
