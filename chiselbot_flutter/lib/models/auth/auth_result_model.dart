import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_result_model.freezed.dart';
part 'auth_result_model.g.dart';

@freezed
class AuthResultModel with _$AuthResultModel {
  const factory AuthResultModel({
    // 로그인/인증 성공 시
    String? token,
    String? userId,
    // 아이디 찾기 성공 시
    String? name,
    String? foundId,
    String? profileImageUrl,
    // 비밀번호 찾기 성공 시
    String? resetToken,
  }) = _AuthResultModel;

  factory AuthResultModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResultModelFromJson(json);
}
