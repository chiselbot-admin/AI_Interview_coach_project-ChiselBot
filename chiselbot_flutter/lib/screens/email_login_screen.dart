import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../core/app_router.dart';
import '../providers/auth_notifier.dart';
import 'main_screen.dart';
import 'signup_screen.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      next.when(
        (isLoading, isLoggedIn, user, token, errorMessage) {
          // 에러 메시지 표시
          if (errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
            ref.read(authNotifierProvider.notifier).clearError();
          }

          // 로그인 성공 시 메인 화면으로 이동
          final wasLoggedIn = previous?.maybeWhen(
            (prevLoading, prevLoggedIn, prevUser, prevToken, prevError) =>
                prevLoggedIn,
            orElse: () => false,
            unauthenticated: () => false,
          );

          if (isLoggedIn && (previous == null || wasLoggedIn == false)) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        },
        unauthenticated: () {
          // 로그아웃 상태 (필요시 처리)
        },
      );
    });

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: FormBuilder(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const SizedBox(height: 40),
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(
                  labelText: '이메일',
                ),
                validator: FormBuilderValidators.required(
                  errorText: '이메일을 입력해주세요',
                ),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'password',
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                ),
                validator: FormBuilderValidators.required(
                  errorText: '비밀번호를 입력해주세요',
                ),
              ),
              const SizedBox(height: 32),
              state.when(
                (isLoading, isLoggedIn, user, token, errorMessage) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() != true) {
                              return;
                            }
                            _formKey.currentState?.save();
                            final formData = _formKey.currentState?.value;
                            final email = formData?['email'] as String?;
                            final password = formData?['password'] as String?;

                            if (email == null || password == null) return;

                            await ref.read(authNotifierProvider.notifier).login(
                                  email: email,
                                  password: password,
                                );
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 3.0),
                          )
                        : const Text(
                            "로그인",
                            style: TextStyle(color: Colors.white),
                          ),
                  );
                },
                unauthenticated: () {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() != true) return;
                      _formKey.currentState?.save();
                      final formData = _formKey.currentState?.value;
                      final email = formData?['email'] as String?;
                      final password = formData?['password'] as String?;

                      if (email == null || password == null) return;

                      await ref.read(authNotifierProvider.notifier).login(
                            email: email,
                            password: password,
                          );
                    },
                    child: const Text(
                      "로그인",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "회원가입",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Text(" | "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        RoutePaths.findIdPw, // AppRouter에 정의된 경로 사용
                      );
                    },
                    child: const Text(
                      "아이디 · 비밀번호 찾기",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
