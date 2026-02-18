import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';

class ChipGroup extends StatelessWidget {
  final bool isDark;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  const ChipGroup({
    super.key,
    required this.isDark,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isActive = selected == option;
        return GestureDetector(
          onTap: () => onSelected(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColor.primaryDark
                  : (isDark ? Colors.grey[900] : Colors.grey[100]),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isActive
                    ? AppColor.primaryDark
                    : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                width: 1,
              ),
            ),
            child: Text(
              _formatLabel(option),
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatLabel(String value) {
    return value.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
  }
}
