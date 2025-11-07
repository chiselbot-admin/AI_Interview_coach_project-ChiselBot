import 'package:flutter/material.dart';
import '../../models/api_models.dart';

class ResultSummary extends StatelessWidget {
  final CoachFeedback fb;
  const ResultSummary({super.key, required this.fb});

  @override
  Widget build(BuildContext context) {
    final double? sim = fb.similarity; // LEVEL2일 땐 null 가능
    final String grade = fb.grade ?? '';

    // 타이틀/리딩 뱃지 내용 결정
    String title;
    String leadingText;

    if (sim != null) {
      final verdict = (sim >= 0.8)
          ? '합격 가능'
          : (sim >= 0.6)
              ? '보완 필요'
              : '미흡';
      title = '판정: $verdict';
      leadingText = '${(sim * 100).round()}';
    } else if (grade.isNotEmpty) {
      title = '등급: $grade';
      leadingText = grade; // 상/중/하
    } else {
      title = '피드백 요약';
      leadingText = '…';
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(leadingText)),
        title: Text(title),
        subtitle: Text(fb.feedback),
      ),
    );
  }
}
