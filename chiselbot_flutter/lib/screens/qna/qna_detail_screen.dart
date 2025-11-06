import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/qna_provider.dart';
import '../../models/inquiry.dart';

class QnaDetailScreen extends ConsumerStatefulWidget {
  final int inquiryId;
  const QnaDetailScreen({super.key, required this.inquiryId});

  @override
  ConsumerState<QnaDetailScreen> createState() => _QnaDetailScreenState();
}

class _QnaDetailScreenState extends ConsumerState<QnaDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(inquiryDetailProvider(widget.inquiryId));

    return Scaffold(
      appBar: AppBar(title: const Text('문의 상세')),
      body: detailAsync.when(
        data: (inq) {
          return Padding(
            padding: const EdgeInsets.all(14),
            child: ListView(
              children: [
                Text(inq.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  '작성일: ${inq.createdAt.year}-${inq.createdAt.month.toString().padLeft(2, '0')}-${inq.createdAt.day.toString().padLeft(2, '0')}'
                  '  (ID: ${inq.inquiryId})',
                ),
                const SizedBox(height: 14),
                const Text('문의 내용',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(inq.content),
                const Divider(height: 32),
                const Text('관리자 답변',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (inq.answerContent != null && inq.answerContent!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(inq.answerContent!),
                        const SizedBox(height: 6),
                        if (inq.answeredAt != null)
                          Text(
                            '답변일: ${inq.answeredAt!.year}-${inq.answeredAt!.month.toString().padLeft(2, '0')}-${inq.answeredAt!.day.toString().padLeft(2, '0')}',
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 12),
                          ),
                      ],
                    ),
                  )
                else
                  Text('아직 답변이 없습니다.',
                      style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }
}
