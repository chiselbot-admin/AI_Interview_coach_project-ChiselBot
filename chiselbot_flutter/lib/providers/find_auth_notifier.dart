import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../models/auth/find_auth_data.dart';
import '../repositories/i_auth_repository.dart';
import 'auth_notifier.dart';

// FindAuthState 상태를 관리하는 Notifier Provider
final findAuthNotifierProvider =
    StateNotifierProvider<FindAuthNotifier, FindAuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);

  return FindAuthNotifier(repository);
});

class FindAuthNotifier extends StateNotifier<FindAuthState> {
  final IAuthRepository _authRepository;

  FindAuthNotifier(this._authRepository) : super(const FindAuthState());

  /// 이메일 주소의 로컬 파트와 도메인 파트를 마스킹하는 헬퍼 메서드
  String _maskUserId(String email) {
    if (!email.contains('@')) {
      // @가 없으면 일반 문자열 마스킹 (길이에 따라 마스킹 길이 조절 가능)
      return email.substring(0, 1) + '*' * (email.length - 1);
    }

    final parts = email.split('@');
    final localPart = parts[0];
    final domainPart = parts[1];

    // 1. Local Part 마스킹 (앞 3자리만 남기고 마스킹)
    String maskedLocal;
    if (localPart.length <= 3) {
      maskedLocal = localPart.substring(0, 1) + '*' * (localPart.length - 1);
    } else {
      maskedLocal = localPart.substring(0, 3) + '*' * (localPart.length - 3);
    }

    // 2. Domain Part 마스킹 (도메인.com도 처리)
    final domainParts = domainPart.split('.');

    String maskedDomain = domainParts.map((part) {
      // .com 같은 최상위 도메인(마지막 부분)은 마스킹에서 제외
      if (part == domainParts.last) {
        return part;
      }

      // 도메인 앞 3자리만 남기고 마스킹
      if (part.length <= 3) {
        return part.substring(0, 1) + '*' * (part.length - 1);
      }
      return part.substring(0, 3) + '*' * (part.length - 3);
    }).join('.');

    debugPrint("[PROVIDER] 마스킹 처리됨: $maskedLocal@$maskedDomain");
    return '$maskedLocal@$maskedDomain';
  }

  /// 인증 요청 로직 (아이디 찾기 또는 비밀번호 찾기)
  Future<void> requestVerificationCode({
    required String contact,
    required AuthType type,
  }) async {
    // 1. 로딩 상태 시작 및 상태 초기 데이터 업데이트
    state = state.copyWith(
      isLoading: true,
      currentAuthType: type,
      inputContact: contact,
      isCodeSent: false, // 재요청 시 상태 초기화
    );

    try {
      // 2. Repository 호출
      final success = await _authRepository.requestVerification(
        contact: contact,
        type: type,
      );

      // 3. 상태 업데이트 (성공)
      if (success) {
        state = state.copyWith(
          isCodeSent: true,
          isLoading: false,
        );
      }
    } catch (e) {
      // 4. 에러 처리 및 상태 업데이트
      state = state.copyWith(isLoading: false);
      debugPrint("[PROVIDER] 인증 요청 실패: $e");
      rethrow;
    }
  }

  /// 인증번호 확인 로직
  Future<void> verifyCode({
    required String code,
  }) async {
    // 1. 로딩 상태 시작
    state = state.copyWith(isLoading: true);

    if (state.inputContact == null || state.currentAuthType == null) {
      state = state.copyWith(isLoading: false);
      throw Exception("인증 요청 정보가 누락되었습니다. 다시 시도해 주세요.");
    }

    try {
      // 2. Repository 호출 (인증 및 결과 획득)
      final result = await _authRepository.verifyCode(
        contact: state.inputContact!,
        code: code,
        type: state.currentAuthType!,
      );

      // 마스킹 로직 적용 (Provider에서 데이터 가공)
      String? maskedId;
      if (result.foundId != null) {
        maskedId = _maskUserId(result.foundId!);
      }

      // 3. 상태 업데이트 (성공)
      state = state.copyWith(
        isVerified: true,
        isLoading: false,
        foundId: maskedId, // 마스킹된 ID를 상태에 저장
        resetToken: result.resetToken, // 비밀번호 재설정 토큰 저장
      );
    } catch (e) {
      // 4. 에러 처리 및 상태 업데이트
      state = state.copyWith(isLoading: false);
      debugPrint("[PROVIDER] 인증번호 확인 실패: $e");
      rethrow;
    }
  }

  /// 비밀번호 재설정
  Future<void> resetPassword({
    required String newPassword,
  }) async {
    if (state.resetToken == null) {
      throw Exception("재설정 토큰이 없습니다.");
    }

    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.resetPassword(
        resetToken: state.resetToken!,
        newPassword: newPassword,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint("[PROVIDER] 비밀번호 재설정 실패: $e");
      rethrow;
    }
  }

  /// 상태 초기화 (화면 이동 또는 재시작 시)
  void resetState() {
    state = const FindAuthState();
  }
}
