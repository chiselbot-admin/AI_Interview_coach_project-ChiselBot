import '../chat/quick_self_check.dart';
import '../chat/rotating_tips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/qna_provider.dart' show QnaProvider, apiServiceProvider;
import '../../providers/storage_providers.dart';
import '../../services/storage_api.dart';
import '../../widgets/message_bubble.dart';
import 'TipPanel.dart';
import 'hint_panel.dart';
import 'model_with_diff.dart';
import 'result_summary.dart';
import 'level2_feedback_card.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _ctrl = TextEditingController();
  late QnaProvider qna;

  bool _submitted = false; // 코칭 1회 제한
  bool _showModel = false; // 모범답안 토글(로컬)
  bool _saving = false; // 저장 중
  bool _saved = false; // 저장 완료

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

  // 문장 끝 기준으로 자연스럽게 타이핑 세그먼트 분리
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
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: (_saving)
                  // 저장 진행 중: 작은 로딩 인디케이터
                  ? const SizedBox(
                      key: ValueKey('saving'),
                      width: 36,
                      height: 36,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      key: const ValueKey('saveBtn'),
                      iconSize: 28,
                      tooltip: _saved ? '저장 완료' : '보관하기',
                      icon: Icon(
                        _saved
                            ? Icons.check_circle_rounded
                            : Icons.bookmark_add_rounded,
                      ),
                      // 조건: 결과가 있고, 현재 질문이 있고, 저장 안 했고, 로딩 아님
                      onPressed: (qna.lastFeedback != null &&
                              qna.currentQuestion != null &&
                              !_disableSave(qna) &&
                              !_saved)
                          ? () async {
                              final q = qna.currentQuestion!;
                              final fb = qna.lastFeedback!;
                              setState(() => _saving = true);
                              try {
                                final isL2 = q.interviewLevel == 'LEVEL_2';
                                await api.saveStorage(
                                  questionId: q.questionId,
                                  userAnswer: fb.userAnswer,
                                  // LEVEL_1: 기존처럼 similarity/questionAnswer 보냄
                                  similarity:
                                      isL2 ? null : (fb.similarity ?? 0.0),
                                  feedback: fb.feedback ?? '',
                                  hint: fb.hint ?? '',
                                  questionAnswer: isL2
                                      ? null
                                      : (fb.questionAnswer ?? q.answerText),
                                  // LEVEL_2: 새 필드 전송
                                  level: q.interviewLevel,
                                  grade: isL2 ? fb.grade : null,
                                  intentText: isL2 ? fb.intentText : null,
                                  pointText: isL2 ? fb.pointText : null,
                                );
                                if (!mounted) return;
                                setState(() {
                                  _saving = false;
                                  _saved = true; // 저장 완료 → 체크 아이콘 고정
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('보관함에 저장되었습니다.')),
                                );
                                ref.invalidate(storageListProvider);
                                await ref
                                    .read(storageListProvider.notifier)
                                    .refresh();
                              } catch (e) {
                                if (!mounted) return;
                                setState(() => _saving = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('보관 실패: $e')),
                                );
                              }
                            }
                          : null,
                    ),
            ),
          ),
        ],
      ),

      // qna 변경을 즉시 반영
      body: AnimatedBuilder(
        animation: qna,
        builder: (context, _) {
          // 1) 로딩이거나 아직 질문이 없을 때: 스켈레톤만 (이전 말풍선은 렌더하지 않음)
          if (qna.loading || qna.currentQuestion == null) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const _ShimmerCard(),
                        const SizedBox(height: 8),
                        // RotatingTips는 const 생성자가 아닐 수 있으므로 const 금지
                        RotatingTips(
                          messages: const [
                            '의도 분석 중...',
                            '핵심 키워드 추출 중...',
                            '구조 점검 중...',
                            '점수 계산 중...',
                          ],
                          // intervalMs: 2400, // 필요 시 사용
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // 2) 정상 질문 렌더
          final q = qna.currentQuestion!;
          final isL2 = q.interviewLevel == 'LEVEL_2';
          final segments =
              _splitForTyping("[${q.categoryName}] ${q.questionText}");

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // 질문 말풍선(타자 효과) — key로 강제 재시작 (랜덤 문제/다음 문제 시 초기화 보장)
                      MessageBubble(
                        key: ValueKey('q-${q.questionId}-${qna.typingDone}'),
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
                        enabled: qna.typingDone && !_submitted && !qna.loading,
                        decoration: const InputDecoration(
                          hintText: '답변을 입력하세요',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 액션 버튼들
                      Row(
                        children: [
                          // 코칭 받기
                          Expanded(
                            child: FilledButton(
                              onPressed: (!qna.typingDone ||
                                      qna.loading ||
                                      _submitted)
                                  ? null
                                  : () async {
                                      final text = _ctrl.text.trim();
                                      if (text.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('답변을 작성해주세요!')),
                                        );
                                        return;
                                      }
                                      await qna.submitAnswer(text);
                                      if (qna.error != null && mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('코칭 실패: ${qna.error}')),
                                        );
                                      } else {
                                        setState(() {
                                          _submitted = true;
                                          _showModel = false; // 제출 직후 기본 숨김
                                        });
                                      }
                                    },
                              child: Text(qna.loading ? '분석 중…' : '코칭 받기'),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 힌트/팁 버튼 (상태 스위칭)
                          Expanded(
                            child: OutlinedButton(
                              // 레벨2 + 코칭 전이면 onPressed = null 로 비활성화
                              onPressed: qna.loading
                                  ? null
                                  : (() {
                                      final submitted = _submitted ||
                                          (qna.lastFeedback != null);
                                      // L2 & 코칭 전 -> 비활성
                                      if (isL2 && !submitted) return null;

                                      // 나머지 경우에는 실제 동작 콜백 반환
                                      return () {
                                        if (qna.loading) return;

                                        final submittedNow = _submitted ||
                                            (qna.lastFeedback != null);
                                        if (submittedNow) {
                                          // 코칭 후: TIP 토글 (L1/L2 공통)
                                          if (qna.hintVisible)
                                            qna.hideHint(); // 충돌 방지
                                          qna.toggleTipVisible();
                                          return;
                                        }

                                        // 코칭 전 + L1: 키워드 힌트 점진 공개
                                        if (!isL2) {
                                          if (!qna.hintVisible) {
                                            qna.revealHint();
                                          } else {
                                            qna.revealExtraHint();
                                          }
                                        }
                                      };
                                    }()),
                              child: Text(
                                (qna.lastFeedback != null)
                                    ? (qna.tipVisible
                                        ? 'TIP 숨기기'
                                        : 'TIP 보기') // 코칭 후
                                    : (isL2
                                        ? 'TIP'
                                        : '힌트 보기'), // 코칭 전: L2는 'TIP' 이지만 비활성
                              ),
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
                                        _submitted = false;
                                        _showModel = false; // 다음 문제 시 숨김
                                        _saved = false; // 새 문제에서 다시 저장 가능
                                      });

                                      // 힌트/팁 상태 초기화 (중복 방지)
                                      qna.hideHint();
                                      qna.hideTip();

                                      if (qna.error != null && mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '다음 문제 불러오기 실패: ${qna.error}'),
                                          ),
                                        );
                                      } else if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('같은 문제가 나올 수 있습니다.'),
                                          ),
                                        );
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 로딩 중 표시(느리게)
                      if (qna.loading) ...[
                        const _ShimmerCard(),
                        const SizedBox(height: 8),
                        RotatingTips(
                          messages: const [
                            '의도 분석 중...',
                            '핵심 키워드 추출 중...',
                            '구조 점검 중...',
                            '점수 계산 중...',
                          ],
                        ),
                      ],

                      // 결과
                      if (qna.lastFeedback != null && !qna.loading) ...[
                        if (!isL2) ...[
                          // LEVEL_1: 요약 + 모범답안 토글
                          ResultSummary(fb: qna.lastFeedback!),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed:
                                  (qna.lastFeedback?.questionAnswer != null)
                                      ? qna.toggleModelVisible
                                      : null,
                              icon: Icon(qna.modelVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              label: Text(
                                  qna.modelVisible ? '모범답안 숨기기' : '모범답안 보기'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (qna.modelVisible &&
                              qna.lastFeedback?.questionAnswer != null)
                            ModelWithDiff(
                              model: qna.lastFeedback!.questionAnswer!,
                              user: qna.lastFeedback!.userAnswer,
                            ),
                        ] else ...[
                          // LEVEL_2: 등급/의도/포인트 카드
                          Level2FeedbackCard(fb: qna.lastFeedback!),
                        ],
                        const SizedBox(height: 12),
                      ],

                      // 코칭 후: TIP(문단) — L1/L2 공통
                      if (!qna.loading &&
                          qna.lastFeedback != null &&
                          qna.tipVisible)
                        TipPanel(tip: qna.lastFeedback!.hint ?? ''),

                      // 코칭 전: (레벨1만) 키워드 힌트 점진 공개
                      if (qna.hintVisible && !isL2)
                        HintPanel(
                          fb: qna.lastFeedback, // 코칭 전에는 거의 null
                          question: qna.currentQuestion, // 모범답안/질문에서 키워드 추출
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
