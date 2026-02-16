import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final formState = FormBuilder.of(context);
    final values = formState?.value ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Review Your Post',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Ready',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Section: Basic Info
        _buildSectionHeader(
          context,
          'Basic Details',
          Icons.info_outline_rounded,
        ),
        _buildReviewItem(context, 'Job Title', values['title'] ?? 'Not set'),
        _buildReviewItem(context, 'Category', values['category'] ?? 'Not set'),
        _buildReviewItem(context, 'Location', values['location'] ?? 'Not set'),
        _buildReviewItem(
          context,
          'Work Arrangement',
          values['workArrangement'] ?? 'Not set',
        ),
        _buildReviewItem(
          context,
          'Employment Type',
          values['employmentType'] ?? 'Not set',
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Section: Compensation
        _buildSectionHeader(context, 'Compensation', Icons.payments_outlined),
        _buildReviewItem(context, 'Salary', _formatSalary(values)),
        _buildReviewItem(
          context,
          'Application Deadline',
          _formatDate(values['applicationDeadline']),
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Section: Content
        _buildSectionHeader(
          context,
          'Role & Requirements',
          Icons.description_outlined,
        ),
        _buildReviewItem(
          context,
          'Description',
          values['description'] ?? 'Not set',
          isLongText: true,
        ),
        _buildReviewList(
          context,
          'Responsibilities',
          values['responsibilities'],
        ),
        _buildReviewList(context, 'Requirements', values['requirements']),
        _buildReviewList(context, 'Benefits', values['benefits']),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 10),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
    BuildContext context,
    String label,
    String value, {
    bool isLongText = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: isLongText ? FontWeight.normal : FontWeight.w700,
              color: colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList(BuildContext context, String label, dynamic value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (value == null || (value is String && value.isEmpty)) {
      return _buildReviewItem(context, label, 'None listed');
    }

    final items = value is String
        ? value
              .split('\n')
              .where((e) => e.trim().startsWith('• '))
              .map((e) => e.replaceFirst('• ', '').trim())
              .toList()
        : <String>[];

    if (items.isEmpty) return _buildReviewItem(context, label, 'None listed');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
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

  String _formatSalary(Map<String, dynamic> values) {
    final type = values['salaryType'] ?? 'Fixed';
    final min = values['salaryMin'] ?? '0';
    final max = values['salaryMax'] ?? '0';
    final currency = values['salaryCurrency'] ?? 'USD';
    final period = values['salaryPeriod'] ?? 'Month';

    if (type == 'Negotiable') return 'Negotiable';
    if (type == 'Fixed') return '$min $currency / $period';
    return '$min - $max $currency / $period';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'No deadline';
    if (date is DateTime) {
      return DateFormat('MMM dd, yyyy').format(date);
    }
    return date.toString();
  }
}
