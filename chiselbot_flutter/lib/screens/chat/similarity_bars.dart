import 'package:flutter/material.dart';
import '../../models/api_models.dart';

class SimilarityBars extends StatelessWidget {
  final CoachFeedback fb;
  const SimilarityBars({super.key, required this.fb});

  double _keywordCoverage(String model, String user) {
    final kw = RegExp(r'[A-Za-z_][A-Za-z0-9_]+')
        .allMatches(model)
        .map((m) => m.group(0)!.toLowerCase())
        .toSet();
    if (kw.isEmpty) return 0.5;
    final used = RegExp(r'[A-Za-z_][A-Za-z0-9_]+')
        .allMatches(user)
        .map((m) => m.group(0)!.toLowerCase())
        .toSet();
    final hit = kw.intersection(used).length;
    return hit / kw.length;
  }

  double _structureScore(String text) {
    final sentences = text
        .split(RegExp(r'[.!?…\n]+'))
        .where((e) => e.trim().isNotEmpty)
        .length;
    if (sentences <= 1) return 0.4;
    if (sentences == 2) return 0.7;
    return 0.9;
  }

  @override
  Widget build(BuildContext context) {
    final double intent =
        (fb.similarity ?? 0.0).clamp(0.0, 1.0).toDouble(); // null safe
    final double kw = (fb.questionAnswer != null)
        ? _keywordCoverage(fb.questionAnswer!, fb.userAnswer)
            .clamp(0.0, 1.0)
            .toDouble()
        : 0.6;
    final double struct =
        _structureScore(fb.userAnswer).clamp(0.0, 1.0).toDouble();

    Widget bar(String label, double v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$label ${(v * 100).round()}%'),
              LinearProgressIndicator(value: v),
            ],
          ),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          bar('의도 적합도', intent),
          bar('키워드 포함', kw),
          bar('구조/전개', struct),
        ]),
      ),
    );
  }
}
