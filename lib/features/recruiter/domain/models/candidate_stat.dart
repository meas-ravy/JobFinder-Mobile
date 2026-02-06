import 'package:flutter/material.dart';

class CandidateStat {
  const CandidateStat({
    required this.role,
    required this.name,
    required this.percent,
    required this.color,
    required this.count,
  });

  final String role;
  final String name;
  final int percent;
  final Color color;
  final int count;
}
