import 'package:flutter/material.dart';

class ErrorSheet extends StatefulWidget {
  final String title; // 큰 제목(사용자용)
  final String? caption; // 짧은 보조 설명(사용자용)
  final String? mascotAsset; // 캐릭터 이미지 asset
  final String? tip; // 사용자 팁(없으면 미표시)

  final VoidCallback onPrimary; // 필수 주 버튼(다시 시도 등)
  final String primaryLabel;
  final VoidCallback? onSecondary; // 보조 버튼
  final String? secondaryLabel;

  const ErrorSheet({
    super.key,
    required this.title,
    required this.onPrimary,
    required this.primaryLabel,
    this.caption,
    this.mascotAsset,
    this.tip,
    this.onSecondary,
    this.secondaryLabel,
  });

  @override
  State<ErrorSheet> createState() => _ErrorSheetState();
}

class _ErrorSheetState extends State<ErrorSheet> {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    // 닫기 버튼을 우상단에 얹기 위해 Stack 사용
    return Stack(
      children: [
        // 본문 카드
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.mascotAsset != null) const SizedBox(height: 8),

                // 상단: 마스코트를 중앙에 배치
                if (widget.mascotAsset != null) ...[
                  Center(
                    child: Opacity(
                      opacity: 0.9,
                      child: Image.asset(
                        widget.mascotAsset!,
                        width: 96,
                        height: 96,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                // 캡션
                if (widget.caption?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.caption!,
                    textAlign: TextAlign.center,
                    style: t.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],

                if (widget.tip?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.tip!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: widget.onPrimary,
                        icon: const Icon(Icons.refresh),
                        label: Text(widget.primaryLabel),
                      ),
                      if (widget.onSecondary != null &&
                          widget.secondaryLabel != null)
                        OutlinedButton.icon(
                          onPressed: widget.onSecondary,
                          icon: const Icon(Icons.cached_rounded),
                          label: Text(widget.secondaryLabel!),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            tooltip: '닫기',
            splashRadius: 20,
            icon: const Icon(Icons.close_rounded),
            color: Colors.white70,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }
}
