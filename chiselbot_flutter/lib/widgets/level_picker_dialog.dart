import 'package:flutter/material.dart';

/// return: 'LEVEL_1' | 'LEVEL_2' | null(취소)
Future<String?> pickInterviewLevel(BuildContext context) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Theme.of(ctx).colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.school),
                  const SizedBox(width: 8),
                  Text(
                    '레벨 선택',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                    tooltip: '닫기',
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '원하는 난이도를 선택하세요.',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // 큰 버튼 두 개
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(ctx, 'LEVEL_1'),
                      icon: const Icon(Icons.looks_one),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('LEVEL 1'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(ctx, 'LEVEL_2'),
                      icon: const Icon(Icons.looks_two),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('LEVEL 2'),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 안내 문구 (레벨1만 점수/유사도 표시)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.4),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('안내', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 6),
                    Text('• LEVEL 1: 정답 유사도(점수)와 모범답안을 제공합니다.'),
                    Text('• LEVEL 2: 의도/포인트 기반 피드백과 등급(상/중/하)만 제공합니다.'),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  );
}
