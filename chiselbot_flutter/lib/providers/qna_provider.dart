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
  bool hintVisible = false; // 힌트 1차 노출 여부
  int extraHintIndex = 0; // 추가 힌트 단계
  bool modelVisible = false; // 힌트에 답 x
  bool typingDone = false; // 질문 타이핑 완료 여부

  bool loading = false;
  String? error;

  // 질문 불러오기
  Future<void> loadQuestion({
    required int categoryId,
    required String level,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    hintVisible = false;
    extraHintIndex = 0;
    modelVisible = false;
    attemptCount = 0;
    typingDone = false;
    lastFeedback = null;

    try {
      print('질문 요청 categoryId=$categoryId, level=$level');
      final q =
          await api.fetchOneQuestion(categoryId: categoryId, level: level);
      print('질문 수신: ${q.questionText}');
      currentQuestion = q;
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
      modelVisible = false; // ← 항상 비공개
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

  // void revealExtraHint() {
  //   // 모범답안(or 백엔드 hint)이 있으면 거기서 키워드 뽑아서 단계별로 제공
  //   extraHintIndex += 1;
  //   notifyListeners();
  // }

  void revealModel() {
    // 프론트 정책: 시도 2회 이상일 때만 오픈
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

// 답변 등록(관리자) 컨트롤러
// class AnswerInquiryController extends AsyncNotifier<void> {
//   @override
//   Future<void> build() async {}
//
//   Future<void> submit({required int inquiryId, required String answer}) async {
//     state = const AsyncLoading();
//     final api = ref.read(apiServiceProvider);
//     state = await AsyncValue.guard(() async {
//       await api.answerInquiry(inquiryId: inquiryId, answer: answer);
//     });
//   }
// }
//
// final answerInquiryProvider =
//     AsyncNotifierProvider<AnswerInquiryController, void>(
//         () => AnswerInquiryController());
