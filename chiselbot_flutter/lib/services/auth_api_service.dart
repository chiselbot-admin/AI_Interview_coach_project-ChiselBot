import 'package:dio/dio.dart';
import '../models/auth/auth_result_model.dart';
import '../models/login/login_request_model.dart';
import 'api_service.dart';
import 'auth_client.dart';

class AuthApiService {
  final ApiService _apiService;
  final AuthClient _authClient;

  AuthApiService(this._apiService, this._authClient);

  // 외부에서 동일 ApiService를 꺼내 쓰기 위한 게터
  ApiService get api => _apiService;

  Future<AuthResultModel> login({required LoginRequestModel request}) async {
    // 1. URL 경로 확정 (type=Local 사용)
    const String path = '/api/users/login/Local';

    try {
      final Response<Map<String, dynamic>> response =
          await _authClient.dio.post(
        path,
        data: request.toJson(),
      );

      // Dio는 200 응답일 때만 try 블록을 실행
      final Map<String, dynamic> responseData = response.data!;
      final Map<String, dynamic> dataMap =
          responseData['data'] as Map<String, dynamic>;
      final AuthResultModel authResult = AuthResultModel.fromJson(dataMap);
      if (authResult.token != null) {
        _apiService.setToken(authResult.token);
      }
      return authResult;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final String errorMessage =
          responseData?['message'] ?? '알 수 없는 오류가 발생했습니다.';

      if (errorMessage.contains('가입되지 않은 이메일입니다') ||
          errorMessage.contains('잘못된 비밀번호 입니다')) {
        throw Exception(errorMessage);
      }
      throw Exception('로그인 실패: [${e.response?.statusCode}] $errorMessage');
    } catch (e) {
      rethrow;
    }
  }

  // 이메일 인증 코드 발송
  Future<void> sendEmailVerification({required String email}) async {
    const String path = '/api/auth/email/send';

    try {
      await _authClient.dio.post(
        path,
        data: {'email': email},
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final String errorMessage =
          responseData?['message'] ?? '인증번호 전송에 실패했습니다.';
      throw Exception(errorMessage);
    }
  }

  // 이메일 인증 코드 확인
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    const String path = '/api/auth/email/verify';

    try {
      await _authClient.dio.post(
        path,
        data: {
          'email': email,
          'code': code,
        },
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final String errorMessage =
          responseData?['message'] ?? '인증번호 확인에 실패했습니다.';
      throw Exception(errorMessage);
    }
  }

  // 회원가입
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    const String path = '/api/users/signup';

    try {
      await _authClient.dio.post(
        path,
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final String errorMessage = responseData?['message'] ?? '회원가입에 실패했습니다.';
      throw Exception(errorMessage);
    }
  }
}
