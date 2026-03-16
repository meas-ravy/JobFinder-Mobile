import 'package:job_finder/core/helper/typedef.dart';

class InterviewQuestion {
  final String question;
  final String category; // e.g., Technical, Behavioral, Motivational
  final String hint;

  InterviewQuestion({
    required this.question,
    required this.category,
    required this.hint,
  });

  factory InterviewQuestion.fromMap(DataMap map) {
    return InterviewQuestion(
      question: map['question'] ?? '',
      category: map['category'] ?? 'General',
      hint: map['hint'] ?? '',
    );
  }
}

class InterviewFeedback {
  final int score; // 0-10
  final String strengths;
  final String improvements;
  final String modelAnswer;

  InterviewFeedback({
    required this.score,
    required this.strengths,
    required this.improvements,
    required this.modelAnswer,
  });

  factory InterviewFeedback.fromMap(DataMap map) {
    return InterviewFeedback(
      score: map['score'] ?? 0,
      strengths: map['strengths'] ?? '',
      improvements: map['improvements'] ?? '',
      modelAnswer: map['modelAnswer'] ?? '',
    );
  }
}
