import 'package:flutter/material.dart';

class LevelSelectSheet extends StatelessWidget {
  final String categoryTitle;
  const LevelSelectSheet({super.key, required this.categoryTitle});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$categoryTitle 면접 레벨 선택',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // 경고/안내
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: const Text(
                '안내: 레벨1에서만 점수(유사도)와 모범답안을 제공합니다.\n'
                '레벨2는 등급(상/중/하)과 [질문 의도/핵심 포인트] 중심 피드백이 제공됩니다.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, 'LEVEL_1'),
                    child: const Text('레벨1 시작'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, 'LEVEL_2'),
                    child: const Text('레벨2 시작'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
