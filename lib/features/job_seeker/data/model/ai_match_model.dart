import 'package:job_finder/core/helper/typedef.dart';

class AiMatchModel {
  final int matchScore;
  final String relevanceSummary;
  final List<String> topGaps;
  final String advice;

  AiMatchModel({
    required this.matchScore,
    required this.relevanceSummary,
    required this.topGaps,
    required this.advice,
  });

  factory AiMatchModel.fromMap(DataMap map) {
    return AiMatchModel(
      matchScore: map['matchScore'] as int? ?? 0,
      relevanceSummary: map['relevanceSummary'] as String? ?? '',
      topGaps: List<String>.from(map['topGaps'] ?? []),
      advice: map['advice'] as String? ?? '',
    );
  }

  DataMap toMap() {
    return {
      'matchScore': matchScore,
      'relevanceSummary': relevanceSummary,
      'topGaps': topGaps,
      'advice': advice,
    };
  }
}
