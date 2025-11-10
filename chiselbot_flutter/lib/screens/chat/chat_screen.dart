import 'package:ai_interview/services/storage_api.dart';

import '../chat/quick_self_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/qna_provider.dart' show QnaProvider, apiServiceProvider;
import '../../providers/storage_providers.dart';
import '../../widgets/message_bubble.dart';
import 'TipPanel.dart';
import 'hint_panel.dart';
import 'model_with_diff.dart';
import 'result_summary.dart';
import 'level2_feedback_card.dart';
import '../chat/loading_pane.dart';

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

  // 여백 토큰(8pt 그리드) — 화면 전체의 간격을 일관되게 관리합니다.
  static const double g1 = 8; // 작은 간격
  static const double g2 = 12; // 중간
  static const double g3 = 16; // 기본 섹션
  static const double g4 = 24; // 큰 섹션

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    qna = AppProviders.of(context).qna; // AppProviders에서 같은 인스턴스 주입
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
                                // 저장 목록 갱신
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
          // 1) 로딩이거나 아직 질문이 없을 때: Shimmer + 진행도 + 긴 팁(느린 교체)
          if (qna.loading || qna.currentQuestion == null) {
            return LoadingPane(
              // 카드가 너무 위에 붙지 않도록 기본 여백 제공(LoadingPane 기본값 48)
              // 필요 시: topPadding: 72,
              tipInterval: const Duration(milliseconds: 5500), // 긴 팁 느리게 교체
              tips: const [
                '의도 파악 중… \n\n\n질문이 묻는 핵심이 무엇인지\n\n 먼저 한 문장으로 정리해 보세요. '
                    '\n\n그래서 무엇을 답해야 하는지 스스로 납득하면,\n\n 예시와 근거를 고르는 속도가 빨라집니다.',
                '구조 점검 중… \n\n\n“정의 → 단계(2~3) → 예시(1) → 마무리”'
                    '\n\n순서를 지키면 듣는 사람이 따라오기가 쉽습니다.\n\n각 단계는 한두 문장으로 짧게요.',
                '키워드 추출 중… \n\n\n질문 속 키워드를 그대로 답변에 심어 보세요. \n\n면접관은 “질문을 정확히 이해했는가”를\n\n 키워드로 판단하는 경우가 많습니다.',
                '간결화 중… \n\n\n한 문장이 25자를 넘으면\n\n 두 문장으로 나누는 걸 권장합니다. \n\n“왜 중요한가?”를 먼저 말하고,\n\n “어떻게 했는가?”를 그 다음에.',
                '예시 보강 중… \n\n\n자랑거리보다 “문제→행동→결과→교훈” 흐름이 더 강력합니다. \n\n숫자(%)나 Before/After를 1개라도 넣어주면 신뢰도가 확 올라갑니다.',
                '마무리 준비 중… \n\n\n마지막 문장은 “그래서 저는 다음에 이렇게 하겠습니다”처럼\n\n 미래 지향 한 줄이면 충분합니다.',
              ],
              character: Image.asset(
                'assets/images/chiselBot.png',
                width: 160,
                fit: BoxFit.contain,
              ),
            );
          }

          // 2) 정상 질문 렌더
          final q = qna.currentQuestion!;
          final isL2 = q.interviewLevel == 'LEVEL_2';
          final segments =
              _splitForTyping("[${q.categoryName}] ${q.questionText}");

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ListView(
                children: [
                  // (1) 질문 말풍선 — 타자 효과 완료 시 qna.typingDone=true
                  MessageBubble(
                    key: ValueKey('q-${q.questionId}-${qna.typingDone}'),
                    isUser: false,
                    animatedSegments: qna.typingDone ? null : segments,
                    text: qna.typingDone
                        ? "[${q.categoryName}] ${q.questionText}"
                        : null,
                    onCompleted: () => qna.markTypingDone(),
                  ),

                  const SizedBox(height: g3), // 섹션 간격

                  // (2) 답변 입력 박스
                  TextField(
                    controller: _ctrl,
                    maxLines: 5,
                    enabled: qna.typingDone && !_submitted && !qna.loading,
                    decoration: const InputDecoration(
                      hintText: '답변을 입력하세요',
                      border: OutlineInputBorder(),
                      // 내부 여백도 넉넉히
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: g3),

                  // (3) 액션 버튼들
                  Row(
                    children: [
                      // 코칭 받기
                      Expanded(
                        child: SizedBox(
                          height: 44,
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
                      ),
                      const SizedBox(width: g3),

                      // 힌트/팁 버튼 (상태 스위칭)
                      Expanded(
                        child: SizedBox(
                          height: 44,
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
                                        if (qna.hintVisible) {
                                          qna.hideHint(); // 충돌 방지
                                        }
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
                                  ? (qna.tipVisible ? 'TIP 숨기기' : 'TIP 보기')
                                  : (isL2 ? 'TIP' : '힌트 보기'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: g3),

                      // 다음 문제
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8), // 가로 패딩 축소
                            ),
                            icon: const Icon(Icons.skip_next, size: 18),
                            label: const Text(
                              '다음 문제',
                              maxLines: 1,
                              softWrap: false,
                            ),
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
                      ),
                    ],
                  ),

                  const SizedBox(height: g4),

                  // (4) 결과 섹션
                  if (qna.lastFeedback != null && !qna.loading) ...[
                    if (!isL2) ...[
                      // LEVEL_1: 요약 + 모범답안 토글
                      ResultSummary(fb: qna.lastFeedback!),
                      const SizedBox(height: g2),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: (qna.lastFeedback?.questionAnswer != null)
                              ? qna.toggleModelVisible
                              : null,
                          icon: Icon(qna.modelVisible
                              ? Icons.visibility_off
                              : Icons.visibility),
                          label:
                              Text(qna.modelVisible ? '모범답안 숨기기' : '모범답안 보기'),
                        ),
                      ),
                      const SizedBox(height: g2),
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
                    const SizedBox(height: g4),
                  ],

                  // (5) 코칭 후 TIP — L1/L2 공통
                  if (!qna.loading &&
                      qna.lastFeedback != null &&
                      qna.tipVisible) ...[
                    TipPanel(tip: qna.lastFeedback!.hint ?? ''),
                    const SizedBox(height: g4),
                  ],

                  // (6) 코칭 전(LEVEL_1만) 키워드 힌트 점진 공개
                  if (qna.hintVisible && !isL2) ...[
                    HintPanel(
                      fb: qna.lastFeedback, // 코칭 전에는 거의 null
                      question: qna.currentQuestion, // 모범답안/질문에서 키워드 추출
                      extraStep: qna.extraHintIndex,
                      onMore: qna.revealExtraHint,
                    ),
                    const SizedBox(height: g4),
                  ],

                  // (7) 시도 전 빠른 셀프 체크
                  if (!qna.loading &&
                      qna.lastFeedback == null &&
                      _ctrl.text.trim().isNotEmpty) ...[
                    QuickSelfCheck(userAnswer: _ctrl.text),
                    const SizedBox(height: g4),
                  ],
                ],
              ),
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

// ====== 내부 스켈레톤 카드 (로딩Pane와 무관 — 결과 섹션 등에서 필요 시 재사용) ======
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
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

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
