import '../providers/qna_provider.dart';

import '../providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_router.dart';
import 'core/app_theme.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: Root()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ChiselBot, AI Interview Coach",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.themeMode,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: RoutePaths.login, // 로그인 화면으로
    );
  }
}

class Root extends ConsumerWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod에서 동일 인스턴스 꺼내오기
    final api = ref.watch(apiServiceProvider);
    final qna = ref.watch(qnaChangeNotifierProvider);

    return AppProviders.inject(
      api: api,
      qna: qna,
      child: const MyApp(),
    );
  }
}
