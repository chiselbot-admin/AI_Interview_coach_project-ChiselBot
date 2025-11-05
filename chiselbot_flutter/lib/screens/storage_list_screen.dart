import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/storage_providers.dart';
import '../providers/auth_notifier.dart';
import 'storage_detail_screen.dart';

class StorageListScreen extends ConsumerStatefulWidget {
  const StorageListScreen({super.key});

  @override
  ConsumerState<StorageListScreen> createState() => _StorageListScreenState();
}

class _StorageListScreenState extends ConsumerState<StorageListScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 갱신
    Future.microtask(() => ref.read(storageListProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final loggedIn = auth.maybeWhen(
      (isLoading, isLoggedIn, user, token, error) =>
          (isLoggedIn == true) && (token?.isNotEmpty ?? false),
      orElse: () => false,
    );

    // 로그인 유도
    if (!loggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('보관함')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('로그인 후 보관함을 사용할 수 있어요.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  // 너희 로그인 라우트로 이동
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('로그인 하러가기'),
              ),
            ],
          ),
        ),
      );
    }

    final state = ref.watch(storageListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('보관함'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(storageListProvider.notifier).refresh(),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(storageListProvider.notifier).refresh(),
        child: state.loading && state.items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final it = state.items[i];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    // GPT 채팅 리스트 느낌: 제목은 질문 텍스트 앞부분
                    title: Text(
                      it.questionText.isNotEmpty
                          ? it.questionText
                          : '질문 #${it.questionId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      // 날짜 + (레벨/카테고리)
                      '${_friendlyDateTime(it.createdAt)} · ${it.interviewLevel} · ${it.categoryName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('삭제'),
                            content: const Text('이 보관함 항목을 삭제할까요?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('취소')),
                              FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('삭제')),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await ref
                              .read(storageListProvider.notifier)
                              .deleteOne(it.storageId);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('삭제되었습니다.')));
                          }
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                StorageDetailScreen(storageId: it.storageId)),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  String _friendlyDateTime(DateTime dt) {
    // 간단 포맷: yyyy-MM-dd HH:mm
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}
