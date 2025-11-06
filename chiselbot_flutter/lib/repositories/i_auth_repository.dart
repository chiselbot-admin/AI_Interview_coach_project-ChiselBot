import '../models/auth/auth_result_model.dart';
import '../models/auth/find_auth_data.dart';
import '../models/auth/user_update_request_model.dart';
import '../models/user_model.dart';

abstract class IAuthRepository {
  Future<AuthResultModel> login(
      {required String email, required String password});

  Future<void> signUp(UserModel user);

  /// contact와 type을 서버에 전달하여 SMS/이메일 인증번호 전송을 요청합니다.
  Future<bool> requestVerification({
    required String contact, // 휴대폰 번호 또는 이메일
    required AuthType type,
  });

  /// 인증번호 확인 후, 아이디 찾기 결과(foundId) 또는 재설정 토큰(resetToken)을 반환합니다.
  Future<AuthResultModel> verifyCode({
    required String contact,
    required String code,
    required AuthType type,
  });

  /// 재설정 토큰을 사용하여 새 비밀번호로 업데이트를 요청합니다.
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });

  Future<String> findEmailByName({required String name});

  /// 내 정보 조회 (JWT 기반)
  Future<UserModel> getMyProfile({required String token});

  /// 회원정보 수정
  Future<void> updateProfile({
    required String token,
    required UserUpdateRequestModel request,
  });

  Future<AuthResultModel> loginWithKakao({required String accessToken});
}
