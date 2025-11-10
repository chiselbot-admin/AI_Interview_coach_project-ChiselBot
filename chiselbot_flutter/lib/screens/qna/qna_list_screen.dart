import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/qna_provider.dart';
import '../../widgets/inquiry_item.dart';
import '../../models/inquiry.dart';

class QnaListScreen extends ConsumerStatefulWidget {
  const QnaListScreen({super.key});

  @override
  ConsumerState<QnaListScreen> createState() => _QnaListScreenState();
}

class _QnaListScreenState extends ConsumerState<QnaListScreen>
    with WidgetsBindingObserver, RouteAware {
  Timer? _poll;

  // 목록 강제 최신화 헬퍼
  Future<void> _refresh() async {
    // FutureProvider를 새로 평가하고 완료까지 기다림
    await ref.refresh(inquiriesProvider.future);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 최초 진입 시 한 번 최신화)
    Future.microtask(_refresh);

    _poll = Timer.periodic(const Duration(seconds: 20), (_) {
      // 리스트 화면 머무르는 동안 20초마다 최신화
      ref.refresh(inquiriesProvider);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱 포그라운드 복귀 시 최신화
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  @override
  void didPopNext() {
    // 다른 화면에서 돌아왔을 때
    _refresh();
    super.didPopNext();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inquiriesAsync = ref.watch(inquiriesProvider);

    final api = ref.watch(apiServiceProvider);
    final hasAuth = api.getHeaders().containsKey('Authorization');

    return Scaffold(
      appBar: AppBar(title: const Text('1:1 문의')),
      body: inquiriesAsync.when(
        data: (list) {
          if (list.isEmpty) {
            // 비어 있어도 당겨서 새로고침 가능하도록 ListView + AlwaysScrollable
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('문의가 없습니다.')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (_, i) => InquiryItem(
                inquiry: list[i],
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    '/qna/detail',
                    arguments: list[i].inquiryId,
                  );
                  // 상세에서 돌아오면 즉시 최신화
                  if (mounted) _refresh();
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 40),
                    const SizedBox(height: 8),
                    Text('네트워크 오류',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('$e', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: hasAuth
          ? FloatingActionButton.extended(
              onPressed: () async {
                final stillAuthed =
                    api.getHeaders().containsKey('Authorization');
                if (!stillAuthed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인 후 이용 가능합니다.')),
                  );
                  Navigator.pushNamed(context, '/login');
                  return;
                }
                await Navigator.pushNamed(context, '/qna/new');
                if (mounted) _refresh(); // 작성 후 즉시 최신화
              },
              icon: const Icon(Icons.edit),
              label: const Text('문의 작성'),
            )
          : null,
    );
  }
}
