import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

// 사용자 정보 Data
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String email,
    required String password, // 서버로 전송 시에는 암호화 필요
    required String phoneNumber,
    // 회원가입에 필요한 다른 필드들...
    String? name,
    String? userId, // 서버에서 생성된 ID (옵션)
    String? profileImageUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
