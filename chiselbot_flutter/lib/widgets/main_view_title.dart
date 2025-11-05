import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_notifier.dart';

class MainViewTitle extends ConsumerWidget {
  const MainViewTitle(BuildContext context, MediaQueryData mediaQuery,
      {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final authState = ref.watch(authNotifierProvider);
    final userName = authState.maybeWhen(
      (isLoading, isLoggedIn, user, token, errorMessage) {
        if (isLoggedIn && user != null) {
          return user.name?.isNotEmpty == true ? user.name! : '개발자';
        }
        return '개발자';
      },
      orElse: () => '개발자',
    );
    return Padding(
      padding: EdgeInsets.only(
        top: mediaQuery.padding.top + 10,
        left: mediaQuery.size.width * .05,
      ),
      child: Row(
        children: [
          const Text("안녕하세요, ",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("$userName님",
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
