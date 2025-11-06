import '../models/auth/find_auth_data.dart';
import '../models/auth/user_update_request_model.dart';
import '../models/login/login_request_model.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import 'i_auth_repository.dart';
import '../models/auth/auth_result_model.dart';

class AuthRepository implements IAuthRepository {
  final AuthApiService authApiService;

  AuthRepository(this.authApiService);

  @override
  Future<AuthResultModel> login({
    required String email,
    required String password,
  }) async {
    final authResult = await authApiService.login(
      request: LoginRequestModel(email: email, password: password),
    );
    return authResult;
  }

  @override
  Future<void> signUp(UserModel user) async {
    await authApiService.signUp(
      email: user.email,
      password: user.password,
      name: user.name!,
    );
  }

  @override
  Future<bool> requestVerification({
    required String contact,
    required AuthType type,
  }) async {
    if (type == AuthType.signUp) {
      await authApiService.sendEmailVerification(email: contact);
      return true;
    }

    if (type == AuthType.findId) {
      // 이름으로 이메일 찾기는 인증 불필요
      return true;
    }

    if (type == AuthType.findPw) {
      await authApiService.sendPasswordResetCode(email: contact);
      return true;
    }

    throw UnimplementedError('지원하지 않는 인증 타입입니다.');
  }

  @override
  Future<AuthResultModel> verifyCode({
    required String contact,
    required String code,
    required AuthType type,
  }) async {
    if (type == AuthType.signUp || type == AuthType.findPw) {
      await authApiService.verifyEmailCode(email: contact, code: code);
      return const AuthResultModel();
    }

    throw UnimplementedError('지원하지 않는 인증 타입입니다.');
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    await authApiService.resetPassword(
      email: resetToken, // resetToken을 email로 사용
      newPassword: newPassword,
    );
  }

  @override
  Future<UserModel> getMyProfile({required String token}) async {
    return await authApiService.getMyProfile(token: token);
  }

  @override
  Future<void> updateProfile({
    required String token,
    required UserUpdateRequestModel request,
  }) async {
    await authApiService.updateProfile(token: token, request: request);
  }

  @override
  Future<String> findEmailByName({required String name}) async {
    return await authApiService.findEmailByName(name: name);
  }

  @override
  Future<AuthResultModel> loginWithKakao({required String accessToken}) async {
    return await authApiService.loginWithKakao(accessToken: accessToken);
  }
}
