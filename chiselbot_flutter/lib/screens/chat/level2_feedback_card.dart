import 'package:flutter/material.dart';
import '../../models/api_models.dart';

class Level2FeedbackCard extends StatelessWidget {
  final CoachFeedback fb;
  const Level2FeedbackCard({super.key, required this.fb});

  Color _gradeColor(String? g) {
    switch (g) {
      case '상':
        return Colors.greenAccent;
      case '중':
        return Colors.amberAccent;
      case '하':
        return Colors.redAccent;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 등급 배지
            if (fb.grade != null)
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _gradeColor(fb.grade).withOpacity(.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _gradeColor(fb.grade)),
                    ),
                    child: Text('등급: ${fb.grade}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            if (fb.grade != null) const SizedBox(height: 12),

            // 핵심 피드백
            Text('핵심 피드백', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(fb.feedback),

            const SizedBox(height: 12),

            // 질문 의도
            if ((fb.intentText ?? '').isNotEmpty) ...[
              Text('질문 의도',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(fb.intentText!),
              const SizedBox(height: 12),
            ],

            // 핵심 포인트
            if ((fb.pointText ?? '').isNotEmpty) ...[
              Text('핵심 포인트',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(fb.pointText!),
            ],
          ],
        ),
      ),
    );
  }
}
