import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../providers/find_auth_notifier.dart';

class ResetPasswordForm extends ConsumerStatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  ConsumerState<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<ResetPasswordForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  Future<void> _resetPassword() async {
    // 폼 유효성 검사
    if (_formKey.currentState?.validate() != true) return;

    // 폼 값 저장
    _formKey.currentState?.save();
    final formData = _formKey.currentState?.value;
    final newPassword = formData?['newPassword'] as String?;

    if (newPassword == null) return;

    // resetToken 가져오기
    final state = ref.read(findAuthNotifierProvider);
    // final resetToken = state.resetToken;
    final email = state.inputContact;

    try {
      // 비밀번호 재설정
      await ref.read(findAuthNotifierProvider.notifier).resetPassword(
            newPassword: newPassword,
          );

      // 성공 다이얼로그 표시 후 로그인 화면으로 이동
      if (mounted) await _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호 변경 실패: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Row(
            children: [
              Icon(FontAwesomeIcons.check, color: Colors.green),
              SizedBox(width: 8),
              const Text('비밀번호 변경 완료'),
            ],
          ),
          content: const Text('비밀번호가 성공적으로 변경되었습니다.\n로그인 화면으로 이동합니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text(
                '확인',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(findAuthNotifierProvider);
    final isLoading = state.isLoading;

    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          // 새 비밀번호 입력
          FormBuilderTextField(
            name: 'newPassword',
            decoration: InputDecoration(
                labelText: '새 비밀번호',
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off))),
            obscureText: _obscurePassword,
            autofocus: true,
            enabled: !isLoading,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '비밀번호를 입력해주세요.'),
              FormBuilderValidators.minLength(4,
                  errorText: '비밀번호는 4자 이상이어야 합니다.'),
              FormBuilderValidators.maxLength(20,
                  errorText: '비밀번호는 20자 이하여야 합니다.'),
            ]),
          ),

          const SizedBox(height: 16),

          // 비밀번호 확인
          FormBuilderTextField(
            name: 'confirmPassword',
            decoration: InputDecoration(
                labelText: '새 비밀번호 확인',
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePasswordConfirm = !_obscurePasswordConfirm;
                      });
                    },
                    icon: Icon(_obscurePasswordConfirm
                        ? Icons.visibility
                        : Icons.visibility_off))),
            obscureText: _obscurePasswordConfirm,
            enabled: !isLoading,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '비밀번호 확인을 입력해주세요.'),
              (value) {
                final password =
                    _formKey.currentState?.fields['newPassword']?.value;
                if (value != password) {
                  return '비밀번호가 일치하지 않습니다.';
                }
                return null;
              },
            ]),
          ),

          const SizedBox(height: 32),

          // 비밀번호 변경 버튼
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                side: const BorderSide(color: Colors.grey)),
            onPressed: isLoading ? null : _resetPassword,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 3.0),
                  )
                : const Text(
                    "비밀번호 변경",
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}
