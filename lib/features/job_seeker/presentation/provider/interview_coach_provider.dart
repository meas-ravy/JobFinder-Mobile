import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/provider/gemini_service_provider.dart';
import 'package:job_finder/core/services/gemini_service.dart';
import 'package:job_finder/features/job_seeker/data/model/interview_coach_model.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/cv_provider.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/cv_template_factory.dart';
import 'package:pdf/widgets.dart' as pw;

class InterviewCoachState {
  final bool isLoading;
  final String? error;
  final List<InterviewQuestion> questions;
  final int currentQuestionIndex;
  final Map<int, InterviewFeedback> feedbacks;
  final Map<int, String> userAnswers;

  final bool isListening;
  final bool isSpeaking;
  final String currentSpeechText;

  InterviewCoachState({
    this.isLoading = false,
    this.error,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.feedbacks = const {},
    this.userAnswers = const {},
    this.isListening = false,
    this.isSpeaking = false,
    this.currentSpeechText = '',
  });

  InterviewCoachState copyWith({
    bool? isLoading,
    String? error,
    List<InterviewQuestion>? questions,
    int? currentQuestionIndex,
    Map<int, InterviewFeedback>? feedbacks,
    Map<int, String>? userAnswers,
    bool? isListening,
    bool? isSpeaking,
    String? currentSpeechText,
  }) {
    return InterviewCoachState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      feedbacks: feedbacks ?? this.feedbacks,
      userAnswers: userAnswers ?? this.userAnswers,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      currentSpeechText: currentSpeechText ?? this.currentSpeechText,
    );
  }

  InterviewQuestion? get currentQuestion =>
      questions.isNotEmpty && currentQuestionIndex < questions.length
      ? questions[currentQuestionIndex]
      : null;

  bool get isFinished =>
      questions.isNotEmpty && currentQuestionIndex >= questions.length;
}

final interviewCoachProvider =
    StateNotifierProvider.autoDispose<
      InterviewCoachController,
      InterviewCoachState
    >((ref) {
      return InterviewCoachController(ref.watch(geminiServiceProvider), ref);
    });

class InterviewCoachController extends StateNotifier<InterviewCoachState> {
  final GeminiService _geminiService;
  final Ref _ref;

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  String? _currentJobDescription;

  InterviewCoachController(this._geminiService, this._ref)
    : super(InterviewCoachState()) {
    _initVoice();
  }

  Future<void> _initVoice() async {
    await _tts.setLanguage("en-US");

    // Try to find a male voice among available voices
    try {
      final voices = await _tts.getVoices;
      for (var voice in voices) {
        final String name = voice["name"].toString().toLowerCase();
        // Look for common male voice identifiers in name or locale
        if (name.contains("male") ||
            name.contains("iol") ||
            name.contains("iom") ||
            name.contains("tpd")) {
          await _tts.setVoice({
            "name": voice["name"],
            "locale": voice["locale"],
          });
          break;
        }
      }
    } catch (e) {
      debugPrint("Error selecting specific voice: $e");
    }

    await _tts.setPitch(0.9); // Slightly deeper male tone
    await _tts.setSpeechRate(0.45); // Moderate pacing, not rushed
    _tts.setStartHandler(() => state = state.copyWith(isSpeaking: true));
    _tts.setCompletionHandler(() async {
      state = state.copyWith(isSpeaking: false);

      // Sam follows turn-taking rules:
      // If he finished a question, he waits for the candidate's full answer.
      final isQuestionIndex =
          state.currentQuestionIndex < state.questions.length;
      final hasFeedback = state.feedbacks.containsKey(
        state.currentQuestionIndex,
      );

      if (isQuestionIndex && !hasFeedback) {
        await Future.delayed(const Duration(milliseconds: 600));
        startListening();
      } else if (hasFeedback) {
        await Future.delayed(const Duration(seconds: 2));
        nextQuestion();
      }
    });
  }

  Future<void> startInterview(String jobTitle, String jobDescription) async {
    _currentJobDescription = jobDescription;
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Get Resume (Optional)
      Uint8List? pdfBytes;
      final List<CvEntity> cvList;
      final cvListAsync = _ref.read(cvListProvider);

      if (cvListAsync.isLoading) {
        cvList = await _ref.read(cvListProvider.future);
      } else {
        cvList = cvListAsync.value ?? [];
      }

      if (cvList.isNotEmpty) {
        final cv = cvList.first;
        final pdf = pw.Document();
        final strategy = CvTemplateFactory.getStrategy(cv.templateName);
        await strategy.build(pdf, cv);
        pdfBytes = await pdf.save();
      }

      // 2. Generate Questions
      final questionData = await _geminiService.generateInterviewQuestions(
        jobTitle: jobTitle,
        jobDescription: jobDescription,
        pdfBytes: pdfBytes,
      );

      final questions = questionData
          .map((e) => InterviewQuestion.fromMap(e))
          .toList();

      state = state.copyWith(
        isLoading: false,
        questions: questions,
        currentQuestionIndex: 0,
        feedbacks: {},
        userAnswers: {},
      );

      // Auto speak first question
      if (questions.isNotEmpty) {
        speak(questions.first.question);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    state = state.copyWith(isSpeaking: false);
  }

  Future<void> startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          state = state.copyWith(isListening: false);

          // Auto submit if we have text
          if (state.currentSpeechText.trim().length > 3) {
            submitAnswer(state.currentSpeechText, _currentJobDescription ?? '');
          }
        }
      },
      onError: (error) =>
          state = state.copyWith(isListening: false, error: error.errorMsg),
    );

    if (available) {
      state = state.copyWith(isListening: true, currentSpeechText: '');
      _speech.listen(
        onResult: (result) {
          state = state.copyWith(currentSpeechText: result.recognizedWords);
        },
      );
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    state = state.copyWith(isListening: false);
  }

  Future<void> submitAnswer(String answer, String jobDescription) async {
    final currentIdx = state.currentQuestionIndex;
    final currentQuestion = state.currentQuestion;

    if (currentQuestion == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final feedbackData = await _geminiService.evaluateInterviewResponse(
        question: currentQuestion.question,
        response: answer,
        jobDescription: jobDescription,
      );

      if (feedbackData != null) {
        final feedback = InterviewFeedback.fromMap(feedbackData);

        final newUserAnswers = Map<int, String>.from(state.userAnswers);
        newUserAnswers[currentIdx] = answer;

        final newFeedbacks = Map<int, InterviewFeedback>.from(state.feedbacks);
        newFeedbacks[currentIdx] = feedback;

        state = state.copyWith(
          isLoading: false,
          userAnswers: newUserAnswers,
          feedbacks: newFeedbacks,
          currentSpeechText: '', // Clear for next round
        );

        // Speak feedback summary or result
        speak("Here is your feedback. Score is ${feedback.score} out of 10.");
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to evaluate answer",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      final nextIdx = state.currentQuestionIndex + 1;
      state = state.copyWith(
        currentQuestionIndex: nextIdx,
        currentSpeechText: '', // Clear for next round
      );
      speak(state.questions[nextIdx].question);
    } else {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        currentSpeechText: '',
      );
      speak("Mock interview complete! Great job practicing.");
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }
}
