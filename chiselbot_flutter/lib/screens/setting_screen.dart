import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../providers/auth_notifier.dart';
import '../widgets/theme_select_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          // 프로필 수정
          ListTile(
            leading: const Icon(FontAwesomeIcons.circleUser, size: 16),
            title: const Text('프로필 수정'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).pushNamed('/profile-edit');
            },
          ),
          Divider(color: Colors.grey.shade800, indent: 16, endIndent: 16),
          // 화면 테마
          ListTile(
            leading: const Icon(FontAwesomeIcons.circleHalfStroke, size: 16),
            title: const Text('화면 테마'),
            subtitle: const Text('현재 테마: 다크',
                style: TextStyle(fontSize: 12)), // 현재 상태 표시
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
            leading: const Icon(FontAwesomeIcons.bullhorn, size: 16),
            title: const Text('공지사항'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).pushNamed('/notice');
            },
          ),
          Divider(color: Colors.grey.shade800, indent: 16, endIndent: 16),
          // 문의하기 (Q&A)
          ListTile(
            leading: const Icon(FontAwesomeIcons.circleQuestion, size: 16),
            title: const Text('문의하기(Q&A)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).pushNamed('/qna');
            },
          ),
          Divider(color: Colors.grey.shade800, indent: 16, endIndent: 16),
          const SizedBox(height: 320),
          // 로그아웃
          ListTile(
            leading: const Icon(
              FontAwesomeIcons.rightFromBracket,
              size: 16,
              color: Colors.red,
            ),
            title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
