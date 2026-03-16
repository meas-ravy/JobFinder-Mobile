import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/provider/gemini_service_provider.dart';
import 'package:job_finder/core/services/gemini_service.dart';
import 'package:job_finder/features/job_seeker/data/model/ai_match_model.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/cv_provider.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/cv_template_factory.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:pdf/widgets.dart' as pw;

// 1. Premium Status Provider
final premiumStatusProvider =
    StateNotifierProvider<PremiumStatusNotifier, bool>((ref) {
      return PremiumStatusNotifier(ref.watch(secureStorageServiceProvider));
    });

// 1.5 CV Health Score Provider (persists in storage)
final cvHealthScoreProvider =
    StateNotifierProvider<CvHealthScoreNotifier, int?>(
      (ref) => CvHealthScoreNotifier(ref.watch(secureStorageServiceProvider)),
    );

class CvHealthScoreNotifier extends StateNotifier<int?> {
  final SecureStorageService _storage;
  CvHealthScoreNotifier(this._storage) : super(null) {
    _loadScore();
  }

  Future<void> _loadScore() async {
    final scoreStr = await _storage.read(SecureStorageKey.cvHealthScore);
    if (scoreStr != null) {
      state = int.tryParse(scoreStr);
    }
  }

  Future<void> updateScore(int score) async {
    await _storage.write(SecureStorageKey.cvHealthScore, score.toString());
    state = score;
  }
}

class PremiumStatusNotifier extends StateNotifier<bool> {
  final SecureStorageService _storage;
  PremiumStatusNotifier(this._storage) : super(false) {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await _storage.read(SecureStorageKey.isPremium);
    state = status == 'true';
  }

  Future<void> upgrade() async {
    // Simulate payment delay
    await Future.delayed(const Duration(seconds: 2));
    await _storage.write(SecureStorageKey.isPremium, 'true');
    state = true;
  }
}

// 2. AI Match State Model
class AiMatchState {
  final bool isLoading;
  final String? error;
  final AiMatchModel? result;

  AiMatchState({this.isLoading = false, this.error, this.result});

  AiMatchState copyWith({
    bool? isLoading,
    String? error,
    AiMatchModel? result,
  }) {
    return AiMatchState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      result: result ?? this.result,
    );
  }
}

// 3. AI Assistant Controller
final aiAssistantControllerProvider =
    StateNotifierProvider<AiAssistantController, AiMatchState>((ref) {
      return AiAssistantController(ref.watch(geminiServiceProvider), ref);
    });

class AiAssistantController extends StateNotifier<AiMatchState> {
  final GeminiService _geminiService;
  final Ref _ref;

  AiAssistantController(this._geminiService, this._ref) : super(AiMatchState());

  Future<void> analyzeJobMatch(String jobDescription) async {
    state = state.copyWith(isLoading: true, error: null, result: null);

    try {
      // 1. Get the primary CV (wait for it to load if necessary)
      final List<CvEntity> cvList;
      final cvListAsync = _ref.read(cvListProvider);

      if (cvListAsync.isLoading) {
        cvList = await _ref.read(cvListProvider.future);
      } else {
        cvList = cvListAsync.value ?? [];
      }

      if (cvList.isEmpty) {
        state = state.copyWith(isLoading: false, error: 'NO_RESUME');
        return;
      }

      final cv = cvList.first;

      // 2. Generate PDF bytes
      final pdf = pw.Document();
      final strategy = CvTemplateFactory.getStrategy(cv.templateName);
      await strategy.build(pdf, cv);
      final pdfBytes = await pdf.save();

      // 3. Call Gemini
      final response = await _geminiService.analyzeMatch(
        jobDescription: jobDescription,
        pdfBytes: pdfBytes,
      );

      final result = AiMatchModel.fromMap(response);
      
      // Update the persistent health score shown in profile with this match score
      await _ref.read(cvHealthScoreProvider.notifier).updateScore(result.matchScore);
      
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      // Provide a more user-friendly error if it's a known string or just use the exception info
      final errorMsg = e.toString().contains('Quota')
          ? 'Daily AI limit reached. Please try again tomorrow.'
          : e.toString();
      state = state.copyWith(isLoading: false, error: errorMsg);
    }
  }
}
