import 'package:flutter/material.dart';

class TipPanel extends StatelessWidget {
  final String tip;
  const TipPanel({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    if (tip.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TIP', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(
              tip,
              style: const TextStyle(height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}
