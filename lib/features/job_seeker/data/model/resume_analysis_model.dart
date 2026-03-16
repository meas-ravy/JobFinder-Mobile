import 'package:job_finder/core/helper/typedef.dart';

class ResumeAnalysisModel {
  final int healthScore;
  final List<String> missingSkills;
  final String improvementSuggestion;
  final String impactStatement;
  final List<String> strengthPoints;

  ResumeAnalysisModel({
    required this.healthScore,
    required this.missingSkills,
    required this.improvementSuggestion,
    required this.impactStatement,
    required this.strengthPoints,
  });

  factory ResumeAnalysisModel.fromMap(DataMap map) {
    return ResumeAnalysisModel(
      healthScore: map['healthScore'] as int? ?? 0,
      missingSkills: List<String>.from(map['missingSkills'] ?? []),
      improvementSuggestion: map['improvementSuggestion'] as String? ?? '',
      impactStatement: map['impactStatement'] as String? ?? '',
      strengthPoints: List<String>.from(map['strengthPoints'] ?? []),
    );
  }
}
