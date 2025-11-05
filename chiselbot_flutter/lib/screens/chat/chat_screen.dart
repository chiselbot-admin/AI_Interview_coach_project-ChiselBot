// lib/features/chat/chat_screen.dart
import '../chat/quick_self_check.dart';
import '../chat/rotating_tips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/qna_provider.dart' show QnaProvider, apiServiceProvider;
import '../../providers/storage_providers.dart';
import '../../services/storage_api.dart';
import '../../widgets/message_bubble.dart';
import 'hint_panel.dart';
import 'result_summary.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _ctrl = TextEditingController();
  late QnaProvider qna;

  bool _submitted = false; // 코칭 1회 제한 플래그

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    qna = AppProviders.of(context).qna;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<String> _splitForTyping(String text) {
    return text
        .split(RegExp(r'(?<=[.!?…\n])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final api = ref.read(apiServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 면접 코치'),
        actions: [
          IconButton(
            // 아이콘 커짐
            iconSize: 28,
            icon: const Icon(Icons.bookmark_add_rounded),
            tooltip: '보관하기',
            onPressed: (qna.lastFeedback != null &&
                    qna.currentQuestion != null &&
                    !_disableSave(qna))
                ? () async {
                    final q = qna.currentQuestion!;
                    final fb = qna.lastFeedback!;
                    try {
                      // 실제 필드 매핑 (null 안전 처리)
                      await api.saveStorage(
                        questionId: q.questionId,
                        userAnswer: fb.userAnswer,
                        similarity: fb.similarity,
                        feedback: fb.feedback ?? '',
                        hint: fb.hint ?? '',
                      );

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('보관함에 저장되었습니다.')),
                      );
                      // 드로어/목록 최신화
                      ref.invalidate(storageListProvider);
                      await ref.read(storageListProvider.notifier).refresh();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('보관 실패: $e')),
                      );
                    }
                  }
                : null,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: qna,
        builder: (context, _) {
          if (qna.currentQuestion == null) {
            return const Center(child: Text('질문이 없습니다. 메인에서 시작하세요.'));
          }
          final q = qna.currentQuestion!;
          final segments =
              _splitForTyping("[${q.categoryName}] ${q.questionText}");

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // 질문 말풍선(타이핑)
                      MessageBubble(
                        isUser: false,
                        animatedSegments: qna.typingDone ? null : segments,
                        text: qna.typingDone
                            ? "[${q.categoryName}] ${q.questionText}"
                            : null,
                        onCompleted: () => qna.markTypingDone(),
                      ),
                      const SizedBox(height: 12),

                      // 답변 입력
                      TextField(
                        controller: _ctrl,
                        maxLines: 5,
                        enabled: qna.typingDone &&
                            !_submitted &&
                            !qna.loading, // CHANGED
                        decoration: const InputDecoration(
                          hintText: '답변을 입력하세요',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 액션 버튼들
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: (!qna.typingDone ||
                                      qna.loading ||
                                      _submitted)
                                  ? null
                                  : () async {
                                      await qna.submitAnswer(_ctrl.text.trim());
                                      if (qna.error != null && mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('코칭 실패: ${qna.error}')),
                                        );
                                      } else {
                                        setState(() {
                                          _submitted = true; // CHANGED: 1회 제한
                                        });
                                      }
                                    },
                              child: Text(qna.loading ? '분석 중…' : '코칭 받기'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: (qna.loading) ? null : qna.revealHint,
                              child: const Text('힌트 보기'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 다음 문제
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.skip_next),
                              label: const Text('다음 문제'),
                              onPressed: qna.loading
                                  ? null
                                  : () async {
                                      final cur = qna.currentQuestion;
                                      if (cur == null) return;
                                      await qna.loadQuestion(
                                        categoryId: cur.categoryId,
                                        level: cur.interviewLevel,
                                      );
                                      _ctrl.clear();
                                      setState(() {
                                        _submitted = false; //다음 문제 시 재시도 가능
                                      });

                                      if (qna.error != null && mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  '다음 문제 불러오기 실패: ${qna.error}')),
                                        );
                                      } else if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('같은 문제가 나올 수 있습니다.')),
                                        );
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 로딩 (문구 느리게 - RotatingTips에 intervalMs 추가)
                      if (qna.loading) ...[
                        const _ShimmerCard(),
                        const SizedBox(height: 8),
                        const RotatingTips(
                          messages: [
                            '의도 분석 중...',
                            '핵심 키워드 추출 중...',
                            '구조 점검 중...',
                            '점수 계산 중...',
                          ],
                          intervalMs: 2400,
                        ),
                      ],

                      // 결과
                      if (qna.lastFeedback != null && !qna.loading) ...[
                        ResultSummary(fb: qna.lastFeedback!),
                        const SizedBox(height: 8),

                        // CHANGED: Diff 제거, 모범답안 “원문만” 노출
                        if (qna.lastFeedback?.questionAnswer != null)
                          _ModelAnswerBlock(
                            modelText: qna.lastFeedback!.questionAnswer!,
                          ),

                        const SizedBox(height: 12),
                      ],

                      // 힌트(키워드 공개)
                      if (qna.hintVisible)
                        HintPanel(
                          fb: qna.lastFeedback,
                          question: qna.currentQuestion,
                          extraStep: qna.extraHintIndex,
                          onMore: qna.revealExtraHint,
                        ),

                      // 시도 전 빠른 셀프체크
                      if (!qna.loading &&
                          qna.lastFeedback == null &&
                          _ctrl.text.trim().isNotEmpty)
                        QuickSelfCheck(userAnswer: _ctrl.text),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _disableSave(QnaProvider q) {
    // 코칭 결과가 있어야 저장 가능. 로딩/미제출 시 비활성
    return q.loading || q.lastFeedback == null || q.currentQuestion == null;
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('AI 분석 중...', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _ShimmerLine(height: 18),
            SizedBox(height: 8),
            _ShimmerLine(),
            SizedBox(height: 8),
            _ShimmerLine(),
            SizedBox(height: 8),
            _ShimmerLine(),
          ],
        ),
      ),
    );
  }
}

class _ShimmerLine extends StatefulWidget {
  final double height;
  final double radius;
  const _ShimmerLine({this.height = 16, this.radius = 6});

  @override
  State<_ShimmerLine> createState() => _ShimmerLineState();
}

class _ShimmerLineState extends State<_ShimmerLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _c.value * 2, 0),
              end: const Alignment(1.0, 0),
              colors: [
                Colors.white.withOpacity(0.06),
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.06),
              ],
              stops: const [0.2, 0.5, 0.8],
            ),
          ),
        );
      },
    );
  }
}

// 모범답안 전용 블록(가독성 위주)
class _ModelAnswerBlock extends StatelessWidget {
  final String modelText;
  const _ModelAnswerBlock({required this.modelText});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.visibility, size: 16),
                SizedBox(width: 6),
                Text('모범답안', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              modelText,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
