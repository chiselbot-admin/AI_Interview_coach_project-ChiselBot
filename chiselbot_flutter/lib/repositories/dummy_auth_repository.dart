// import 'dart:async';
// import 'package:ai_interview/models/auth/user_update_request_model.dart';
// import 'package:flutter/foundation.dart';
//
// import '../models/auth/auth_result_model.dart';
// import '../models/auth/find_auth_data.dart';
// import '../models/user_model.dart';
// import 'i_auth_repository.dart';
//
// class DummyAuthRepository implements IAuthRepository {
//   static const Duration _delay = Duration(seconds: 1); // 응답 지연 시간 시뮬레이션
//   static const String _dummyCode = "123456"; // 테스트용 인증번호
//   static const String _dummyUserId = "test123@naver.com"; // 찾은 아이디
//
//   // ========================== 1. 로그인 ==========================
//   @override
//   Future<AuthResultModel> login(
//       {required String email, required String password}) async {
//     await Future.delayed(_delay);
//     debugPrint("[DUMMY REPO] 로그인 시도: $email");
//
//     // 성공 응답 가정
//     return const AuthResultModel(
//       token: 'dummy_jwt_token_12345',
//       userId: 'dummy_user_id_1',
//     );
//   }
//
//   // ========================== 2. 회원가입 ==========================
//   @override
//   Future<void> signUp(UserModel user) async {
//     await Future.delayed(_delay);
//     debugPrint("[DUMMY REPO] 회원가입 시도: ${user.email}");
//     return; // 성공 시 void 반환
//   }
//
//   // ========================== 3. 인증번호 요청 (ID/PW 찾기) ==========================
//   @override
//   Future<bool> requestVerification({
//     required String contact,
//     required AuthType type,
//   }) async {
//     await Future.delayed(_delay);
//     final typeName = type == AuthType.findId
//         ? "휴대폰(ID)"
//         : type == AuthType.findPw
//             ? "이메일(PW)"
//             : "회원가입 이메일";
//     debugPrint(
//         "[DUMMY REPO] $typeName 인증 요청 ($contact): 인증번호 $_dummyCode 전송 가정");
//     // 서버가 인증번호 전송에 성공했다고 가정하고 true 반환
//     return true;
//   }
//
//   // ========================== 4. 인증번호 확인 ==========================
//   @override
//   Future<AuthResultModel> verifyCode({
//     required String contact,
//     required String code,
//     required AuthType type,
//   }) async {
//     await Future.delayed(_delay);
//
//     if (code == _dummyCode) {
//       debugPrint("[DUMMY REPO] 인증번호 일치. 결과 반환.");
//
//       if (type == AuthType.findId) {
//         // 아이디 찾기 성공: foundId를 담아 반환
//         return const AuthResultModel(foundId: _dummyUserId);
//       } else if (type == AuthType.findPw) {
//         return const AuthResultModel(resetToken: 'dummy_reset_token_0987');
//       } else {
//         return const AuthResultModel();
//       }
//     } else {
//       debugPrint("[DUMMY REPO] 인증번호 불일치.");
//       // 실패 시 Provider가 처리할 수 있도록 에러 발생
//       throw Exception("인증번호가 일치하지 않거나 만료되었습니다.");
//     }
//   }
//
//   // ========================== 5. 비밀번호 재등록 ==========================
//   @override
//   Future<void> resetPassword({
//     required String resetToken,
//     required String newPassword,
//   }) async {
//     await Future.delayed(_delay);
//     debugPrint("[DUMMY REPO] 비밀번호 재등록 성공 (토큰: $resetToken)");
//     return;
//   }
//
//   @override
//   Future<UserModel> getMyProfile({required String token}) async {
//     await Future.delayed(_delay);
//     debugPrint("[DUMMY REPO] 내 정보 조회");
//     return UserModel(
//       email: 'test@example.com',
//       password: '',
//       phoneNumber: '010-1234-5678',
//       name: '홍길동',
//       userId: 'dummy_user_id_1',
//     );
//   }
//
//   @override
//   Future<void> updateProfile({
//     required String token,
//     required UserUpdateRequestModel request,
//   }) async {
//     await Future.delayed(_delay);
//     debugPrint("[DUMMY REPO] 회원정보 수정: ${request.name}");
//     return;
//   }
// }
