import 'package:flutter/material.dart';

final List<TempModel> allTemp = [
  TempModel(
    name: 'Normal',
    displayName: 'Celeste',
    category: 'Simple',
    icon: 'assets/image/sampleone.png',
    color: Color(0xFF6C63FF),
  ),
  TempModel(
    name: 'Professional',
    displayName: 'Aurora',
    category: 'Professional',
    icon: 'assets/image/profesionalone.png',
    color: Color(0xFF6C63FF),
  ),
];

List<TempModel> filteredTemp = [];

class TempModel {
  final String name;
  final String displayName;
  final String category;
  final String icon;
  final Color color;

  TempModel({
    required this.name,
    required this.displayName,
    required this.category,
    required this.icon,
    required this.color,
  });
}
