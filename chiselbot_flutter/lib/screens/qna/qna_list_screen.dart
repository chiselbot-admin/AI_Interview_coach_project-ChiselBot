import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/qna_provider.dart';
import '../../widgets/inquiry_item.dart';
import '../../models/inquiry.dart';

class QnaListScreen extends ConsumerWidget {
  const QnaListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiriesAsync = ref.watch(inquiriesProvider);

    // JWT 존재 여부로 로그인 판단
    final api = ref.watch(apiServiceProvider);
    final hasAuth = api.getHeaders().containsKey('Authorization');

    return Scaffold(
      appBar: AppBar(title: const Text('1:1 문의')),
      body: inquiriesAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('문의가 없습니다.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(inquiriesProvider),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) => InquiryItem(
                inquiry: list[i],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/qna/detail',
                    arguments: list[i].inquiryId,
                  ).then((_) => ref.invalidate(inquiriesProvider));
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 40),
                const SizedBox(height: 8),
                Text('네트워크 오류', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('$e', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(inquiriesProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: hasAuth
          ? FloatingActionButton.extended(
              onPressed: () {
                // 토큰 만료 등의 경우를 대비해 한 번 더 체크
                final stillAuthed =
                    api.getHeaders().containsKey('Authorization');
                if (!stillAuthed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인 후 이용 가능합니다.')),
                  );
                  Navigator.pushNamed(context, '/login');
                  return;
                }
                Navigator.pushNamed(context, '/qna/new')
                    .then((_) => ref.invalidate(inquiriesProvider));
              },
              icon: const Icon(Icons.edit),
              label: const Text('문의 작성'),
            )
          : null,
    );
  }
}
