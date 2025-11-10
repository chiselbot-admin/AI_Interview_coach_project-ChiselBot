import 'package:flutter/material.dart';

class ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onDetails;

  const ErrorPanel({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 520),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_rounded, size: 28, color: Colors.redAccent),
          const SizedBox(height: 8),
          const Text(
            '문제가 발생했어요',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '네트워크 상태를 확인한 뒤 다시 시도해 주세요.',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onDetails,
                icon: const Icon(Icons.info_outline),
                label: const Text('자세히'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '오류 메세지: ${_short(message)}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static String _short(String s) {
    const max = 80;
    if (s.length <= max) return s;
    return s.substring(0, max) + '…';
  }
}
