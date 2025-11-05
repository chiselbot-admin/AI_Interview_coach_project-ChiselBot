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

class StorageDetail extends StorageItem {
  StorageDetail({
    required super.storageId,
    required super.questionId,
    required super.userId,
    required super.questionText,
    required super.userAnswer,
    required super.feedback,
    required super.hint,
    required super.similarity,
    required super.interviewLevel,
    required super.categoryName,
    required super.createdAt,
  });

  factory StorageDetail.fromJson(Map<String, dynamic> j) => StorageDetail(
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
        createdAt: StorageItem._parseCreatedAt(j['createdAt']?.toString()),
      );
}
