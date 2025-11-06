import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/storage_providers.dart';

class StorageDetailScreen extends ConsumerWidget {
  final int storageId;
  const StorageDetailScreen({super.key, required this.storageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(storageDetailProvider(storageId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('보관함 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '삭제',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('삭제'),
                  content: const Text('이 보관 항목을 삭제할까요?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                try {
                  await ref
                      .read(storageListProvider.notifier)
                      .deleteOne(storageId);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('삭제 실패: $e')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러올 수 없습니다: $e')),
        data: (d) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // 헤더 카드
              Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.04),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.questionText.isNotEmpty
                            ? d.questionText
                            : '질문 #${d.questionId}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_friendlyDateTime(d.createdAt)} · ${d.interviewLevel} · ${d.categoryName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _section(context, title: '내 답변', body: d.userAnswer),
              const SizedBox(height: 12),
              _section(context,
                  title: '피드백', body: d.feedback.isNotEmpty ? d.feedback : '—'),
              const SizedBox(height: 12),
              // _section(context,
              //     title: '힌트', body: d.hint.isNotEmpty ? d.hint : '—'),
              // const SizedBox(height: 12),
              if (d.questionAnswer.isNotEmpty) ...[
                const SizedBox(height: 12),
                _section(context, title: '모범답안', body: d.questionAnswer),
              ],
              if (d.similarity != null) ...[
                const SizedBox(height: 12),
                _SimilarityGauge(value: d.similarity!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context,
      {required String title, required String body}) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.03),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            SelectableText(body, style: const TextStyle(height: 1.35)),
          ],
        ),
      ),
    );
  }

  String _friendlyDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}

// 유사도 시각화
class _SimilarityGauge extends StatelessWidget {
  final double value; // 0.0 ~ 1.0
  const _SimilarityGauge({required this.value});

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    final percent = (v * 100).round();

    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('유사도', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 6),
            Text('$percent%', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
