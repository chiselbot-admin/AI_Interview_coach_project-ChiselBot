class StorageItem {
  final int storageId;
  final int questionId;
  final int userId;
  final String questionText;
  final String userAnswer;
  final String feedback;
  final String hint;
  final double? similarity;
  final String interviewLevel;
  final String categoryName;
  final DateTime createdAt;
  final String questionAnswer;

  StorageItem({
    required this.storageId,
    required this.questionId,
    required this.userId,
    required this.questionText,
    required this.userAnswer,
    required this.feedback,
    required this.hint,
    required this.similarity,
    required this.interviewLevel,
    required this.categoryName,
    required this.createdAt,
    required this.questionAnswer,
  });

  factory StorageItem.fromJson(Map<String, dynamic> j) {
    final created = j['createdAt']?.toString();
    return StorageItem(
      storageId: j['storageId'],
      questionId: j['questionId'],
      userId: j['userId'],
      questionText: j['questionText'] ?? '',
      userAnswer: j['userAnswer'] ?? '',
      feedback: j['feedback'] ?? '',
      hint: j['hint'] ?? '',
      similarity: (j['similarity'] as num?)?.toDouble(),
      interviewLevel: j['interviewLevel'] ?? '',
      categoryName: j['categoryName'] ?? '',
      questionAnswer: j['questionAnswer'] ?? '',
      createdAt: _parseCreatedAt(created),
    );
  }

  static DateTime _parseCreatedAt(String? s) {
    if (s == null) return DateTime.now();
    // "yyyy-MM-dd HH:mm" (또는 ISO) 로 내려오므로 안전 파서
    try {
      return DateTime.parse(s.replaceFirst(' ', 'T'));
    } catch (_) {
      // 수동 파싱: "yyyy-MM-dd HH:mm"
      final parts = s.split(' ');
      if (parts.length == 2) {
        final d = parts[0].split('-').map(int.parse).toList();
        final t = parts[1].split(':').map(int.parse).toList();
        return DateTime(d[0], d[1], d[2], t[0], t[1]);
      }
      return DateTime.now();
    }
  }
}

class StorageDetail {
  final int storageId;
  final int questionId;

  // 헤더/메타
  final String? questionText;
  final String? categoryName;
  final String? interviewLevel;
  final String? level;
  final DateTime createdAt;

  // 공통
  final String userAnswer;
  final String? feedback;
  final String? hint;

  // LEVEL_1 전용
  final double? similarity;
  final String? questionAnswer;

  // LEVEL_2 전용
  final String? grade;
  final String? intentText;
  final String? pointText;

  StorageDetail({
    required this.storageId,
    required this.questionId,
    required this.userAnswer,
    required this.createdAt,
    this.questionText,
    this.categoryName,
    this.interviewLevel,
    this.level,
    this.feedback,
    this.hint,
    this.similarity,
    this.questionAnswer,
    this.grade,
    this.intentText,
    this.pointText,
  });

  factory StorageDetail.fromJson(Map<String, dynamic> j) {
    // createdAt은 "yyyy-MM-dd HH:mm" 또는 ISO 로 온다고 가정
    DateTime _parseCreatedAt(String? s) {
      if (s == null) return DateTime.now();
      try {
        return DateTime.parse(s.replaceFirst(' ', 'T'));
      } catch (_) {
        final parts = s.split(' ');
        if (parts.length == 2) {
          final d = parts[0].split('-').map(int.parse).toList();
          final t = parts[1].split(':').map(int.parse).toList();
          return DateTime(d[0], d[1], d[2], t[0], t[1]);
        }
        return DateTime.now();
      }
    }

    return StorageDetail(
      storageId: j['storageId'],
      questionId: j['questionId'],
      userAnswer: j['userAnswer'] ?? '',
      createdAt: _parseCreatedAt(j['createdAt']?.toString()),
      questionText: j['questionText'],
      categoryName: j['categoryName'],
      interviewLevel: j['interviewLevel'],
      level: j['level'],
      feedback: j['feedback'],
      hint: j['hint'],
      similarity:
          (j['similarity'] is num) ? (j['similarity'] as num).toDouble() : null,
      questionAnswer: j['questionAnswer'],
      grade: j['grade'],
      intentText: j['intentText'],
      pointText: j['pointText'],
    );
  }
}
