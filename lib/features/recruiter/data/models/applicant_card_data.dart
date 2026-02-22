import 'package:flutter/material.dart';

class ApplicantCardData {
  const ApplicantCardData({
    required this.name,
    required this.date,
    required this.role,
    required this.snippet,
    required this.attachments,
    this.avatarUrl,
  });

  final String name;
  final String date;
  final String role;
  final String snippet;
  final List<AttachmentData> attachments;
  final String? avatarUrl;
}

class AttachmentData {
  const AttachmentData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
