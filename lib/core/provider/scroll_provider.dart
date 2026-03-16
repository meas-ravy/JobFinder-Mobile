import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// tap tap scroll to top
final jobSeekerHomeScrollControllerProvider = Provider((ref) {
  final controller = ScrollController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

final recruiterHomeScrollControllerProvider = Provider((ref) {
  final controller = ScrollController();
  ref.onDispose(() => controller.dispose());
  return controller;
});
