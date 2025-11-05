import 'package:flutter/material.dart';
import '../../models/api_models.dart';

class HintPanel extends StatelessWidget {
  final CoachFeedback? fb; // 시도 후 서버 피드백
  final InterviewQuestion? question; // 시도 전 fallback
  final int extraStep; // 공개할 키워드 개수
  final VoidCallback onMore;

  const HintPanel({
    super.key,
    required this.fb,
    required this.question,
    required this.extraStep,
    required this.onMore,
  });

  // 키워드만 뽑기 (한/영/숫자 토큰)
  List<String> _keywordsFrom(String text) {
    final toks = RegExp(r'[A-Za-z가-힣0-9_]+')
        .allMatches(text)
        .map((m) => m.group(0)!)
        .toList();

    const stop = {
      'the',
      'a',
      'an',
      'and',
      'or',
      'of',
      'to',
      'in',
      'on',
      'is',
      'are',
      'was',
      'were',
      'be',
      'for',
      '이',
      '그',
      '저',
      '그리고',
      '또는',
      '에서',
      '으로',
      '에게',
      '이다',
      '있는',
      '없는'
    };

    final uniq = <String>{};
    final out = <String>[];

    for (final t in toks) {
      final k = t.toLowerCase();
      if (k.length < 2 || k.length > 20) continue; // 너무 길면 제외
      if (stop.contains(k)) continue;
      if (RegExp(r'^\d+$').hasMatch(k)) continue; // 숫자 단독 제외
      if (uniq.add(k)) out.add(t);
      if (out.length >= 30) break;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    // 모범답안 > 서버 힌트 > 시도 전: question.answerText(LEVEL_1) > question.questionText
    final source = () {
      if (fb?.questionAnswer != null && fb!.questionAnswer!.isNotEmpty) {
        return fb!.questionAnswer!;
      }
      if (fb?.hint != null && fb!.hint!.isNotEmpty) {
        return fb!.hint!;
      }
      if (question?.answerText != null && question!.answerText!.isNotEmpty) {
        return question!.answerText!;
      }
      return question?.questionText ?? '';
    }();

    final kws = _keywordsFrom(source);
    final revealCount = extraStep.clamp(0, kws.length);
    final shown = kws.take(revealCount).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('힌트(키워드)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (shown.isEmpty)
            const Text('첫 번째 힌트를 받으려면 [추가 힌트]를 눌러주세요.',
                style: TextStyle(fontSize: 12)),
          if (shown.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: -8,
              children: shown.map((k) => Chip(label: Text(k))).toList(),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: (revealCount < kws.length) ? onMore : null,
              child: const Text('추가 힌트'),
            ),
          ),
        ]),
      ),
    );
  }
}
