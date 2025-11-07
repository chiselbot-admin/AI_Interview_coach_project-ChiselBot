import 'package:flutter/material.dart';
import '../../models/api_models.dart';

/// 힌트 패널
/// - LEVEL_1: 제출 전 → question.answerText 기반 키워드(점진 공개)
///            제출 후 → fb.hint만 사용(없으면 answerText)
/// - LEVEL_2: 제출 전 → 힌트 비공개 안내
///            제출 후 → 키워드칩이 아니라 '문단 전체' 한 번에 노출
class HintPanel extends StatelessWidget {
  final CoachFeedback? fb; // 시도 후 서버 피드백
  final InterviewQuestion? question; // 시도 전 fallback
  final int extraStep; // L1에서만 사용 (점진 공개)
  final VoidCallback onMore;

  const HintPanel({
    super.key,
    required this.fb,
    required this.question,
    required this.extraStep,
    required this.onMore,
  });

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
      if (k.length < 2 || k.length > 20) continue;
      if (stop.contains(k)) continue;
      if (RegExp(r'^\d+$').hasMatch(k)) continue;
      if (uniq.add(k)) out.add(t);
      if (out.length >= 30) break;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final level = question?.interviewLevel?.toUpperCase();
    final isLevel2 = level == 'LEVEL_2';
    final hasFb = fb != null;

    // ========== LEVEL 2 ==========
    if (isLevel2) {
      if (!hasFb) {
        // 제출 전: 안내만
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('힌트', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'LEVEL 2 힌트는 답변을 제출한 뒤, AI의 의도/포인트 분석 결과를 기반으로 제공돼요.\n'
                  '먼저 [코칭 받기]를 눌러 답변을 제출해 주세요.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        );
      }

      // 제출 후: "한 번에 전체" 문단 노출 (칩/추가 힌트 버튼 없음)
      final full = (fb!.hint?.trim().isNotEmpty == true)
          ? fb!.hint!.trim()
          : ((fb!.pointText?.trim().isNotEmpty == true)
              ? fb!.pointText!.trim()
              : '추출 가능한 힌트가 없습니다.');

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('힌트', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SelectableText(full, style: const TextStyle(height: 1.35)),
            ],
          ),
        ),
      );
    }

    // ========== LEVEL 1 ==========
    // 제출 후: fb.hint만 사용(모범답안에서 키워드 뽑기 제거!)
    // 제출 전: question.answerText → 없으면 questionText
    final source = () {
      if (hasFb && fb!.hint != null && fb!.hint!.isNotEmpty) {
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
