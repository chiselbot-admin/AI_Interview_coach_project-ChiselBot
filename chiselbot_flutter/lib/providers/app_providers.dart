import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'qna_provider.dart';

class AppProviders extends InheritedWidget {
  final ApiService api;
  final QnaProvider qna;

  const AppProviders.inject({
    super.key,
    required super.child,
    required this.api,
    required this.qna,
  });

  static AppProviders of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppProviders>()!;

  @override
  bool updateShouldNotify(covariant AppProviders oldWidget) => false;
}
