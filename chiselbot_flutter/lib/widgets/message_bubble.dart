import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

// AI 면접 질문이나 사용자의 대답을 말풍선 형태로 보여주는 위젯
class MessageBubble extends StatelessWidget {
  // 누가 말했는지 구분
  final bool isUser;

  // 일반 텍스트
  final String? text;

  // 타자 효과 문장 리스트
  final List<String>? animatedSegments;

  // 타이핑 속도와 문장 사이의 간격
  final Duration speed;
  final Duration pauseBetweenSegments;

  // 타자 효과 완료 콜백
  final VoidCallback? onCompleted;

  const MessageBubble({
    super.key,
    required this.isUser,
    this.text,
    this.animatedSegments,
    this.speed = const Duration(milliseconds: 60),
    this.pauseBetweenSegments = const Duration(milliseconds: 800),
    this.onCompleted,
  }) : assert(
          (text != null) ^ (animatedSegments != null),
          'text 또는 animatedSegments 중 하나만 지정하세요.',
        );

  @override
  Widget build(BuildContext context) {
    final bg = isUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceVariant;
    final fg = isUser
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    Widget child;
    if (animatedSegments != null) {
      child = AnimatedTextKit(
        key: ValueKey(animatedSegments!.join('|')), // 내용 바뀌면 애니 재시작
        animatedTexts: animatedSegments!
            .map((s) => TypewriterAnimatedText(
                  s,
                  speed: speed,
                  textStyle: TextStyle(color: fg, fontSize: 15),
                ))
            .toList(),
        totalRepeatCount: 1,
        pause: pauseBetweenSegments,
        displayFullTextOnTap: true,
        stopPauseOnTap: true,
        onFinished: onCompleted,
      );
    } else {
      child = Text(
        text!,
        style: TextStyle(color: fg, fontSize: 15),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }
}
