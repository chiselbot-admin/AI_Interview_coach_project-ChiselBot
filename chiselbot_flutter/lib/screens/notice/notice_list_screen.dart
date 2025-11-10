import 'package:ai_interview/core/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/notice_provider.dart';
import '../../widgets/notice_list_item.dart';

class NoticeListScreen extends ConsumerWidget {
  const NoticeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(noticesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: noticesAsync.when(
        data: (allNotices) {
          final visibleNotices =
              allNotices.where((notice) => notice.isVisible).toList();
          if (visibleNotices.isEmpty) {
            return const Center(child: Text('공지사항이 없습니다.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(noticesProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: visibleNotices.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (_, i) {
                final notice = visibleNotices[i];
                return NoticeListItem(
                  notice: notice,
                  onTap: () {
                    Navigator.pushNamed(context, RoutePaths.noticeDetail,
                        arguments: notice.id);
                  },
                );
              },
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
                const Icon(Icons.error_outline, size: 40, color: Colors.orange),
                const SizedBox(height: 8),
                Text(
                  '공지사항을 불러올 수 없습니다',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text('$e', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(noticesProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
