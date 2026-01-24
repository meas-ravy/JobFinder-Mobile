import 'package:flutter/material.dart';

class ApplicantCardData {
  const ApplicantCardData({
    required this.name,
    required this.date,
    required this.role,
    required this.snippet,
    required this.attachments,
  });

  final String name;
  final String date;
  final String role;
  final String snippet;
  final List<AttachmentData> attachments;
}

class AttachmentData {
  const AttachmentData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const List<ApplicantCardData> applicants = [
  ApplicantCardData(
    name: 'Jane Cooper',
    date: '5 Jan 2023',
    role: 'Product designer',
    snippet: 'Applied for Product designer, Hi Fifi...',
    attachments: [
      AttachmentData(label: 'Resume', icon: Icons.description_outlined),
      AttachmentData(label: 'Cover Letter', icon: Icons.article_outlined),
    ],
  ),
  ApplicantCardData(
    name: 'Jane Cooper',
    date: '5 Jan 2023',
    role: 'Product designer',
    snippet: 'Applied for Product designer, Hi Fifi...',
    attachments: [
      AttachmentData(label: 'CV', icon: Icons.badge_outlined),
      AttachmentData(label: 'Portfolio', icon: Icons.work_outline_rounded),
    ],
  ),
  ApplicantCardData(
    name: 'Jane Cooper',
    date: '5 Jan 2023',
    role: 'Product designer',
    snippet: 'Applied for Product designer, Hi Fifi...',
    attachments: [
      AttachmentData(label: 'Resume', icon: Icons.description_outlined),
    ],
  ),
  ApplicantCardData(
    name: 'Jane Cooper',
    date: '5 Jan 2023',
    role: 'Product designer',
    snippet: 'Applied for Product designer, Hi Fifi...',
    attachments: [
      AttachmentData(label: 'CV', icon: Icons.badge_outlined),
      AttachmentData(label: 'Cover Letter', icon: Icons.article_outlined),
    ],
  ),
  ApplicantCardData(
    name: 'Jane Cooper',
    date: '5 Jan 2023',
    role: 'Product designer',
    snippet: 'Applied for Product designer, Hi Fifi...',
    attachments: [
      AttachmentData(label: 'Resume', icon: Icons.description_outlined),
    ],
  ),
];

Map<String, Color> buildAttachmentPalette(ColorScheme scheme) {
  return {
    'Resume': scheme.primary,
    'Cover Letter': scheme.secondary,
    'CV': scheme.tertiary,
    'Portfolio': scheme.primary,
  };
}
