import 'dart:async';
import 'package:flutter/material.dart';

class RotatingTips extends StatefulWidget {
  final List<String> messages;
  final int intervalMs; // 기본 전환 간격

  const RotatingTips({
    super.key,
    required this.messages,
    this.intervalMs = 1200, // 기존 기본값 유지
  });

  @override
  State<RotatingTips> createState() => _RotatingTipsState();
}

class _RotatingTipsState extends State<RotatingTips> {
  int _index = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(Duration(milliseconds: widget.intervalMs), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % widget.messages.length);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Text(
        widget.messages[_index],
        key: ValueKey(_index),
      ),
    );
  }
}
