import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/app_router.dart';
import '../providers/auth_notifier.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKakaoLoginButton(context, ref),
            const SizedBox(height: 16),
            _buildGoogleLoginButton(),
            const SizedBox(height: 16),
            _buildEmailLoginButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildKakaoLoginButton(BuildContext context, WidgetRef ref) {
    final imgAddress = 'assets/images/kakao_login_black.png';
    return InkWell(
      onTap: () async {
        try {
          await ref.read(authNotifierProvider.notifier).loginWithKakao();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, RoutePaths.main);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('카카오 로그인 실패: $e')),
            );
          }
        }
      },
      child: Container(
        height: 42,
        width: 185,
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                imgAddress,
                height: 28,
              ),
              Text(
                "카카오 로그인",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return InkWell(
      onTap: () {
        //
      },
      child: Container(
        height: 42,
        width: 185,
        decoration: BoxDecoration(
          color: Colors.blue.shade400,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                FontAwesomeIcons.google,
                color: Colors.black,
                size: 20,
              ),
              Text(
                "  구글 로그인 ",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailLoginButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, RoutePaths.emailLogin);
      },
      child: Container(
        height: 40,
        width: 185,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(210),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                FontAwesomeIcons.envelope,
                color: Colors.black,
                size: 20,
              ),
              Text(
                "이메일 로그인",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5),
              )
            ],
          ),
        ),
      ),
    );
  }
}
