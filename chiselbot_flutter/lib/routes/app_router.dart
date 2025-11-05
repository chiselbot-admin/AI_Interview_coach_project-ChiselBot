// import 'package:flutter/material.dart';
//
// // --- 스크린 임포트 (여기만 관리) ---
// import 'package:ai_interview/screens/splash_screen.dart';
// import 'package:ai_interview/screens/onboarding_screen.dart';
// import 'package:ai_interview/screens/main_screen.dart';
// import 'package:ai_interview/screens/chat/chat_screen.dart';
//
// // QnA
// import 'package:ai_interview/screens/qna/qna_list_screen.dart';
// import 'package:ai_interview/screens/qna/qna_form_screen.dart';
// import 'package:ai_interview/screens/qna/qna_detail_screen.dart';
//
// // --- 라우트 상수 ---
// import 'package:ai_interview/screens/chat/chat_screen.dart';
// import 'package:ai_interview/screens/main_screen.dart';
// import 'package:ai_interview/screens/qna/qna_detail_screen.dart';
// import 'package:ai_interview/screens/qna/qna_form_screen.dart';
// import 'package:ai_interview/screens/qna/qna_list_screen.dart';
// import 'package:ai_interview/screens/splash_screen.dart';
// import 'package:flutter/material.dart';
//
// class RoutePaths {
//   static const root = '/';
//   static const main = '/main';
//   static const chat = '/chat';
//
//   static const qna = '/qna';
//   static const qnaNew = '/qna/new';
//   static const qnaDetail = '/qna/detail';
// }
//
// // --- 인자 객체 (타입 안전) ---
// class QnaDetailArgs {
//   final int inquiryId;
//   QnaDetailArgs(this.inquiryId);
// }
//
// // --- 라우트 생성기 ---
// class AppRouter {
//   static Route<dynamic>? generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case RoutePaths.root:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
//
//       case RoutePaths.main:
//         return MaterialPageRoute(builder: (_) => const MainScreen());
//
//       case RoutePaths.chat:
//         return MaterialPageRoute(builder: (_) => const ChatScreen());
//
//       case RoutePaths.qna:
//         return MaterialPageRoute(builder: (_) => const QnaListScreen());
//
//       case RoutePaths.qnaNew:
//         return MaterialPageRoute(builder: (_) => const QnaFormScreen());
//
//       case RoutePaths.qnaDetail:
//         // 인자 검증 (int 또는 QnaDetailArgs 모두 허용)
//         final args = settings.arguments;
//         if (args is int) {
//           return MaterialPageRoute(
//               builder: (_) => QnaDetailScreen(inquiryId: args));
//         } else if (args is QnaDetailArgs) {
//           return MaterialPageRoute(
//               builder: (_) => QnaDetailScreen(inquiryId: args.inquiryId));
//         } else {
//           return _error('Invalid arguments for /qna/detail');
//         }
//
//       default:
//         return _unknown(settings.name);
//     }
//   }
//
//   static Route<dynamic> _unknown(String? name) {
//     return MaterialPageRoute(
//       builder: (_) => Scaffold(
//         appBar: AppBar(title: const Text('Unknown Route')),
//         body: Center(child: Text('Unknown route: $name')),
//       ),
//     );
//   }
//
//   static Route<dynamic> _error(String message) {
//     return MaterialPageRoute(
//       builder: (_) => Scaffold(
//         appBar: AppBar(title: const Text('Route Error')),
//         body: Center(child: Text(message)),
//       ),
//     );
//   }
// }
