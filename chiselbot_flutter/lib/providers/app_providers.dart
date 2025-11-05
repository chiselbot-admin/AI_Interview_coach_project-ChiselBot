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

// Riverpod에서 꺼낸 인스턴스 주입으로 변경
// class AppProviders extends InheritedWidget {
//   final ApiService api;
//   final QnaProvider qna;
//
//   // 내부 생성자: 이미 만들어둔 인스턴스를 주입
//   const AppProviders._({
//     super.key,
//     required super.child,
//     required this.api,
//     required this.qna,
//   });
//
//   // 외부에서 쓰는 생성자(팩토리): 여기서 한 번만 만들고 넘김
//   factory AppProviders({
//     Key? key,
//     required Widget child,
//     required String baseUrl,
//   }) {
//     final api = ApiService(baseUrl);
//     final qna = QnaProvider(api);
//     return AppProviders._(
//       key: key,
//       child: child,
//       api: api,
//       qna: qna,
//     );
//   }
//
//   static AppProviders of(BuildContext context) =>
//       context.dependOnInheritedWidgetOfExactType<AppProviders>()!;
//
//   @override
//   bool updateShouldNotify(covariant AppProviders oldWidget) => false;
// }
