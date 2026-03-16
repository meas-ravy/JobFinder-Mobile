import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable labeled section wrapper
Widget buildSection(
  BuildContext context,
  String title, {
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(height: 12),
      child,
    ],
  );
}

/// A row with icon + label on the left and value on the right
Widget buildInfoRow(
  BuildContext context,
  Widget icon,
  String label,
  String value,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        icon,
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    ),
  );
}

/// Colored pill badge showing application status
Widget buildStatusBadge(BuildContext context, String status) {
  Color color;
  Color bgColor;

  switch (status) {
    case 'Hired':
      color = Colors.green;
      bgColor = Colors.green.withValues(alpha: 0.1);
      break;
    case 'Rejected':
      color = Colors.red;
      bgColor = Colors.red.withValues(alpha: 0.1);
      break;
    default:
      color = Colors.orange;
      bgColor = Colors.orange.withValues(alpha: 0.1);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

/// Formats a date value into dd/mm/yyyy string
String formatDate(dynamic date) {
  if (date == null) return 'N/A';
  try {
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    if (date is int) {
      final dt = DateTime.fromMillisecondsSinceEpoch(date);
      return '${dt.day}/${dt.month}/${dt.year}';
    }
    final dt = DateTime.parse(date.toString());
    return '${dt.day}/${dt.month}/${dt.year}';
  } catch (_) {
    return 'N/A';
  }
}
