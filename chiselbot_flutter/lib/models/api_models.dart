class ApiEnvelope<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiEnvelope({required this.success, this.data, this.error});

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) convert,
  ) {
    return ApiEnvelope(
      success: json['success'] == true,
      data: json['data'] != null ? convert(json['data']) : null,
      error: json['error'] as String?,
    );
  }
}

class InterviewCategory {
  final int categoryId;
  final String name;
  InterviewCategory({required this.categoryId, required this.name});

  factory InterviewCategory.fromJson(Map<String, dynamic> j) =>
      InterviewCategory(categoryId: j['categoryId'], name: j['name']);
}

// 화면에 보여줄 질문 최소 필드 (백엔드 FindById DTO에 맞춤)
class InterviewQuestion {
  final int questionId;
  final String questionText;
  final String interviewLevel;
  final String categoryName;
  final String? answerText; // LEVEL_1에서만 채움(백엔드에서 내려줄 때)
  final int categoryId;

  InterviewQuestion({
    required this.questionId,
    required this.questionText,
    required this.interviewLevel,
    required this.categoryName,
    this.answerText,
    required this.categoryId,
  });

  factory InterviewQuestion.fromJson(Map<String, dynamic> j) =>
      InterviewQuestion(
        questionId: j['questionId'],
        questionText: j['questionText'],
        interviewLevel: j['interviewLevel'],
        categoryName: j['categoryName'],
        answerText: j['answerText'],
        categoryId: j['categoryId'],
      );
}

// 코칭 응답(FeedbackResponse.FeedbackResult에 맞춤)
class CoachFeedback {
  final int questionId;
  final double? similarity;
  final String feedback;
  final String? hint; // 유사도 < 0.8일 때만
  final String userAnswer;
  final String? questionAnswer; // LEVEL_1에서 기대
  // LEVEL_2
  final String? intentText; // 질문 의도
  final String? pointText; // 핵심 포인트
  final String? grade; // 상,중,하

  CoachFeedback({
    required this.questionId,
    required this.similarity,
    required this.feedback,
    required this.userAnswer,
    this.hint,
    this.questionAnswer,
    this.intentText,
    this.pointText,
    this.grade,
  });

  factory CoachFeedback.fromJson(Map<String, dynamic> j) => CoachFeedback(
        questionId: j['questionId'],
        similarity: (j['similarity'] as num).toDouble(),
        feedback: j['feedback'],
        hint: j['hint'],
        userAnswer: j['userAnswer'],
        questionAnswer: j['questionAnswer'],
        intentText: j['intentText'],
        pointText: j['pointText'],
        grade: j['grade'],
      );
}
