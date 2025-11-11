import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/app_router.dart';
import '../providers/auth_notifier.dart';
import '../widgets/theme_select_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(currentUserInfoProvider);
    final bool isUserLoggedIn = userInfo.$4;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Divider(color: Colors.grey.shade800, indent: 16, endIndent: 16),
          // 프로필 수정
          ListTile(
            leading: const Icon(FontAwesomeIcons.circleUser, size: 24),
            title: const Text('프로필 수정'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).pushNamed(RoutePaths.profileEdit);
            },
          ),
          Divider(color: Colors.grey.shade800, indent: 16, endIndent: 16),
          // 화면 테마
          ListTile(
            leading: const Icon(FontAwesomeIcons.circleHalfStroke, size: 24),
            title: const Text('화면 테마'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ThemeSelectDialog(),
              );
            },
          ),
          Divider(color: Colors.grey.shade800, indent: 16, endIndent: 16),
          // 공지사항
          ListTile(
            leading: const Icon(FontAwesomeIcons.bullhorn, size: 24),
            title: const Text('공지사항'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).pushNamed(RoutePaths.notice);
            },
          ),
          Divider(color: Colors.grey.shade800, indent: 16, endIndent: 16),
          // 문의하기 (Q&A)
          ListTile(
            leading: const Icon(FontAwesomeIcons.circleQuestion, size: 24),
            title: const Text('문의하기(Q&A)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).pushNamed(RoutePaths.qna);
            },
          ),
          Divider(color: Colors.grey.shade800, indent: 16, endIndent: 16),
          if (isUserLoggedIn) ...[
            // 로그아웃
            ListTile(
              leading: const Icon(FontAwesomeIcons.rightFromBracket,
                  size: 24, color: Colors.redAccent),
              title:
                  const Text('로그아웃', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      RoutePaths.login, (route) => false);
                }
              },
            ),
            Divider(color: Colors.grey.shade800, indent: 16, endIndent: 16),
          ]
        ],
      ),
    );
  }
}
