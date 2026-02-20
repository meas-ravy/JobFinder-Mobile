import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final formState = FormBuilder.of(context);
    final values = formState?.value ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Your Post',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Make sure everything is correct',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Ready',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Section: Basic Info
        _buildSectionCard(
          context,
          title: 'Basic Details',
          icon: Icons.info_outline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPrimaryReviewItem(
                context,
                'Job Title',
                values['title'] ?? 'Not set',
                icon: Icons.work_outline_rounded,
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  _buildGridReviewItem(
                    context,
                    'Category',
                    values['category'] ?? 'Not set',
                    Icons.category_outlined,
                  ),
                  _buildGridReviewItem(
                    context,
                    'Location',
                    values['location'] ?? 'Not set',
                    Icons.location_on_outlined,
                  ),
                  _buildGridReviewItem(
                    context,
                    'Arrangement',
                    values['workArrangement'] ?? 'Not set',
                    Icons.laptop_mac_rounded,
                  ),
                  _buildGridReviewItem(
                    context,
                    'Type',
                    values['employmentType'] ?? 'Not set',
                    Icons.history_toggle_off_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Section: Compensation
        _buildSectionCard(
          context,
          title: 'Compensation \u0026 Deadline',
          icon: Icons.payments_outlined,
          child: Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _buildGridReviewItem(
                context,
                'Salary Range',
                _formatSalary(values),
                Icons.currency_exchange_rounded,
              ),
              _buildGridReviewItem(
                context,
                'Application Deadline',
                _formatDate(values['applicationDeadline']),
                Icons.calendar_month_outlined,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Section: Description
        _buildSectionCard(
          context,
          title: 'Role Description',
          icon: Icons.description_outlined,
          child: _buildLongTextItem(
            context,
            values['description'] ?? 'No description provided',
          ),
        ),

        const SizedBox(height: 20),

        // Section: Lists
        _buildSectionCard(
          context,
          title: 'Requirements \u0026 Benefits',
          icon: Icons.list_alt_rounded,
          child: Column(
            children: [
              _buildPremiumReviewList(
                context,
                'Key Responsibilities',
                values['responsibilities'],
                Icons.task_alt_rounded,
              ),
              const SizedBox(height: 20),
              _buildPremiumReviewList(
                context,
                'Job Requirements',
                values['requirements'],
                Icons.shield_outlined,
              ),
              const SizedBox(height: 20),
              _buildPremiumReviewList(
                context,
                'Benefits \u0026 Perks',
                values['benefits'],
                Icons.card_giftcard_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildPrimaryReviewItem(
    BuildContext context,
    String label,
    String value, {
    required IconData icon,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
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
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridReviewItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: (MediaQuery.of(context).size.width - 120) / 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLongTextItem(BuildContext context, String text) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildPremiumReviewList(
    BuildContext context,
    String label,
    dynamic value,
    IconData icon,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final String content = value is String ? value : '';
    final List<String> items = content
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e.startsWith('•') ? e.substring(1).trim() : e)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Text(
            'None listed',
            style: textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatSalary(Map<String, dynamic> values) {
    final type = values['salaryType'] ?? 'Fixed';
    final min = values['salaryMin'] ?? '0';
    final max = values['salaryMax'] ?? '0';
    final currency = values['salaryCurrency'] ?? 'USD';
    final period = values['salaryPeriod'] ?? 'Month';

    if (type == 'Negotiable') return 'Negotiable';
    if (type == 'Fixed') return '$min $currency/$period';
    return '$min - $max $currency/$period';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'No deadline';
    if (date is DateTime) {
      return DateFormat('MMM dd, yyyy').format(date);
    }
    return date.toString();
  }
}
