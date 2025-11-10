import 'dart:async';
import 'package:flutter/material.dart';

/// 로딩 UX: Shimmer + 느린 장문 팁 회전 + (선택) 캐릭터 이미지
class LoadingPane extends StatefulWidget {
  // 화면 하단을 채울 문장 팁들
  final List<String> tips;

  // 팁 교체 주기 — 기본 3.2초(느리게)
  final Duration tipInterval;

  // 상단 카드 제목
  final String title;

  // 상단 여백 (기본 40px)
  final double topPadding;

  // (신규) 하단 캐릭터 위젯 (예: Image.asset(...))
  final Widget? character;

  // (신규) 캐릭터와 TIP 사이 간격
  final double characterTopSpacing;

  // 팁 글자 크기 스케일(기본 1.2배)
  final double tipTextScale;

  // 캐릭터가 차지할 예약 높이(스크롤 방지용)
  //   - 캐릭터 이미지 실제 높이 근처로 설정(예: 140~200)
  final double characterReservedHeight;

  const LoadingPane({
    super.key,
    required this.tips,
    this.tipInterval = const Duration(milliseconds: 3200),
    this.title = 'AI 분석 중...',
    this.topPadding = 40,
    this.character,
    this.characterTopSpacing = 12,
    this.tipTextScale = 1.2,
    this.characterReservedHeight = 160,
  });

  @override
  State<LoadingPane> createState() => _LoadingPaneState();
}

class _LoadingPaneState extends State<LoadingPane> {
  Timer? _tipTick;
  int _tipIndex = 0;

  @override
  void initState() {
    super.initState();
    // 긴 팁 문구 느리게 교체
    _tipTick = Timer.periodic(widget.tipInterval, (_) {
      if (!mounted) return;
      setState(() => _tipIndex = (_tipIndex + 1) % widget.tips.length);
    });
  }

  @override
  void dispose() {
    _tipTick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12 + widget.topPadding, 12, 12),
      child: Column(
        children: [
          // (1) 상단 Shimmer 카드
          _ShimmerCard(title: widget.title),
          const SizedBox(height: 12),

          // (2) TIP (가운데 정렬, 폭 제한)
          Expanded(
            child: Stack(
              children: [
                // (A) TIP: 가운데 정렬 + 아래에 캐릭터 높이만큼 여유 패딩
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: (widget.character != null
                          ? widget.characterReservedHeight +
                              widget.characterTopSpacing
                          : 0),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: ConstrainedBox(
                        key: ValueKey(_tipIndex),
                        constraints: const BoxConstraints(maxWidth: 560),
                        // 글자가 커져도 화면 밖으로 나가지 않도록 scaleDown
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: SelectableText(
                            widget.tips[_tipIndex],
                            textAlign: TextAlign.center,
                            // 글자 크기 스케일 (기본 1.2배)
                            textScaleFactor: widget.tipTextScale,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  height: 1.5,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // (B) 캐릭터: 항상 하단 중앙, 고정 높이로 예약
                if (widget.character != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: widget.characterTopSpacing),
                        SizedBox(
                          height: widget.characterReservedHeight,
                          child: _BobbingCharacter(
                            bob: 10,
                            duration: const Duration(milliseconds: 2600),
                            breathe: true,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: widget.character!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 내부용 Shimmer 카드
class _ShimmerCard extends StatelessWidget {
  final String title;
  const _ShimmerCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // 제목은 상단에서 그대로 사용
            // (텍스트 위젯 분리: 외부에서 스타일 관리 용이)
            // ignore: prefer_const_constructors
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

// ================= 애니메이션 래퍼: 캐릭터에 살짝 뜨는 효과 + 미세한 스케일/투명도 =================
class _BobbingCharacter extends StatefulWidget {
  final Widget child;
  final double bob; // 위아래 이동 px (기본 8)
  final Duration duration; // 왕복 시간 (기본 2.4s)
  final bool breathe; // 살짝 스케일/투명도 변화를 줄지

  const _BobbingCharacter({
    required this.child,
    this.bob = 8,
    this.duration = const Duration(milliseconds: 2400),
    this.breathe = true,
  });

  @override
  State<_BobbingCharacter> createState() => _BobbingCharacterState();
}

class _BobbingCharacterState extends State<_BobbingCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (_, __) {
        // t: 0~1 —> -bob/2 ~ +bob/2
        final dy = (widget.bob * (_t.value - 0.5));
        // 숨쉬기: 0.98 ~ 1.02 (아주 미세)
        final scale = widget.breathe ? (0.98 + (_t.value * 0.04)) : 1.0;
        // 투명도: 0.9 ~ 1.0 (미세)
        final opacity = widget.breathe ? (0.9 + (_t.value * 0.1)) : 1.0;

        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
