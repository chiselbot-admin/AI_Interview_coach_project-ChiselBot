import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_models.dart'; // InterviewCategory/Question/CoachFeedback
import '../models/inquiry.dart'; // Inquiry 모델
import '../services/api_service.dart';
import '../services/auth_api_service.dart';
import 'auth_notifier.dart';

/// 면접 코칭용
class QnaProvider extends ChangeNotifier {
  final ApiService api;
  QnaProvider(this.api);

  InterviewQuestion? currentQuestion;
  CoachFeedback? lastFeedback;

  // 프론트 전용 UX 상태
  int attemptCount = 0; // 시도 횟수 (프론트에서만 증가)
  bool hintVisible = false; // 힌트 1차 노출 여부 (L1: 코칭 전 키워드 힌트에만 사용)
  int extraHintIndex = 0; // 추가 힌트 단계
  bool modelVisible = false; // 모범 답안 토글 (L1 코칭 후 전용)
  bool typingDone = false; // 질문 타이핑 완료 여부

  // TIP 토글 (코칭 후, L1/L2 공통으로 "문단 팁"을 한 번에 노출)
  bool _tipVisible = false;
  bool get tipVisible => _tipVisible;
  void toggleTipVisible() {
    _tipVisible = !_tipVisible;
    notifyListeners();
  }

  void hideTip() {
    if (_tipVisible) {
      _tipVisible = false;
      notifyListeners();
    }
  }

  // 힌트 숨김도 명시적으로 제공(다음 문제에서 초기화 시 사용)
  void hideHint() {
    if (hintVisible || extraHintIndex != 0) {
      hintVisible = false;
      extraHintIndex = 0;
      notifyListeners();
    }
  }

  bool loading = false;
  String? error;

  // 질문 불러오기
  Future<void> loadQuestion({
    required int categoryId,
    required String level,
  }) async {
    loading = true;
    error = null;

    // 이전 질문을 즉시 비워서 화면에 남지 않게
    currentQuestion = null;
    // 타자 효과/힌트/피드백 상태 초기화
    hintVisible = false;
    extraHintIndex = 0;
    modelVisible = false;
    attemptCount = 0;
    typingDone = false;
    lastFeedback = null;
    _tipVisible = false; // 🔹 TIP도 초기화

    notifyListeners();

    try {
      print('질문 요청 categoryId=$categoryId, level=$level');
      final q =
          await api.fetchOneQuestion(categoryId: categoryId, level: level);
      print('질문 수신: ${q.questionText}');
      currentQuestion = q; // 새 질문 세팅
    } catch (e) {
      error = e.toString();
      currentQuestion = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // 사용자 답변 제출 + 코칭 요청
  Future<void> submitAnswer(String userAnswer) async {
    if (currentQuestion == null) {
      error = '질문이 없습니다.';
      notifyListeners();
      return;
    }

    // 중복 요청 방지: 이미 요청 중이면 return
    if (loading) return;

    loading = true;
    error = null;
    notifyListeners();
    try {
      final fb = await api.coach(
        questionId: currentQuestion!.questionId,
        userAnswer: userAnswer,
      );
      lastFeedback = fb;
      attemptCount = 1; // ← 고정(표시 용도 없어도 안전하게 유지)
      modelVisible = false; // ← 항상 비공개 시작
      _tipVisible = false; // ← TIP도 기본은 숨김으로
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // 힌트: 첫 클릭 시 바로 1개 키워드가 보이도록
  void revealHint() {
    hintVisible = true;
    if (extraHintIndex == 0) extraHintIndex = 1; // 첫 힌트 버튼 = 첫 키워드
    notifyListeners();
  }

  // 힌트 추가 공개 (한 번 누를 때마다 키워드 1개씩 더 보여주기)
  void revealExtraHint() {
    extraHintIndex += 1;
    notifyListeners();
  }

  void revealModel() {
    // 프론트 정책: 시도 2회 이상일 때만 오픈 (현재는 사용 안 해도 안전)
    if (attemptCount >= 2) {
      modelVisible = true;
      notifyListeners();
    }
  }

  // 모범 답안 토글
  void toggleModelVisible() {
    modelVisible = !modelVisible;
    notifyListeners();
  }

  void markTypingDone() {
    typingDone = true;
    notifyListeners();
  }
}

/// QnA(1:1 문의)용

// authApiServiceProvider에서 같은 ApiService 인스턴스 재사용
final apiServiceProvider = Provider<ApiService>((ref) {
  final authApi = ref.watch(authApiServiceProvider);
  return authApi.api; // <-- AuthApiService에 추가한 getter (ApiService get api)
});

final qnaChangeNotifierProvider = ChangeNotifierProvider<QnaProvider>((ref) {
  final api = ref.watch(apiServiceProvider);
  return QnaProvider(api);
});

// 문의 목록
final inquiriesProvider = FutureProvider<List<Inquiry>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchInquiries();
});

// 문의 상세 (family)
final inquiryDetailProvider =
    FutureProvider.family<Inquiry, int>((ref, inquiryId) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchInquiryDetail(inquiryId);
});

// 문의 등록(사용자) 컨트롤러
class CreateInquiryController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {} // 상태 초기화

  Future<void> submit({required String title, required String content}) async {
    state = const AsyncLoading();
    final api = ref.read(apiServiceProvider);
    state = await AsyncValue.guard(() async {
      await api.createInquiry(title: title, content: content);
    });
  }
}

final createInquiryProvider =
    AsyncNotifierProvider<CreateInquiryController, void>(
        () => CreateInquiryController());
