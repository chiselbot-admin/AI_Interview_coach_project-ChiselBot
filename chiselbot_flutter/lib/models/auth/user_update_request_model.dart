import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_update_request_model.freezed.dart';
part 'user_update_request_model.g.dart';

/// 회원정보 수정 요청 모델
@freezed
class UserUpdateRequestModel with _$UserUpdateRequestModel {
  const factory UserUpdateRequestModel({
    required String name, // 2-20자 (서버 검증)
    required String password, // 4-20자 (서버 검증)
  }) = _UserUpdateRequestModel;

  /// JSON → Model
  factory UserUpdateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateRequestModelFromJson(json);
}
