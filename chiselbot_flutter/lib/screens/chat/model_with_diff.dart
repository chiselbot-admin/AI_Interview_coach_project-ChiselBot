import 'package:flutter/material.dart';

// 모범 답안
class ModelWithDiff extends StatelessWidget {
  final String model;
  final String user;
  const ModelWithDiff({super.key, required this.model, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('모범답안', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(
              model,
              textAlign: TextAlign.start,
              style: const TextStyle(height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}
