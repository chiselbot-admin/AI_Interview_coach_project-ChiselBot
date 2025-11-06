// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthResultModel _$AuthResultModelFromJson(Map<String, dynamic> json) {
  return _AuthResultModel.fromJson(json);
}

/// @nodoc
mixin _$AuthResultModel {
// 로그인/인증 성공 시
  String? get token => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError; // 아이디 찾기 성공 시
  String? get name => throw _privateConstructorUsedError;
  String? get foundId => throw _privateConstructorUsedError;
  String? get profileImageUrl =>
      throw _privateConstructorUsedError; // 비밀번호 찾기 성공 시
  String? get resetToken => throw _privateConstructorUsedError;

  /// Serializes this AuthResultModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResultModelCopyWith<AuthResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResultModelCopyWith<$Res> {
  factory $AuthResultModelCopyWith(
          AuthResultModel value, $Res Function(AuthResultModel) then) =
      _$AuthResultModelCopyWithImpl<$Res, AuthResultModel>;
  @useResult
  $Res call(
      {String? token,
      String? userId,
      String? name,
      String? foundId,
      String? profileImageUrl,
      String? resetToken});
}

/// @nodoc
class _$AuthResultModelCopyWithImpl<$Res, $Val extends AuthResultModel>
    implements $AuthResultModelCopyWith<$Res> {
  _$AuthResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = freezed,
    Object? userId = freezed,
    Object? name = freezed,
    Object? foundId = freezed,
    Object? profileImageUrl = freezed,
    Object? resetToken = freezed,
  }) {
    return _then(_value.copyWith(
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      foundId: freezed == foundId
          ? _value.foundId
          : foundId // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      resetToken: freezed == resetToken
          ? _value.resetToken
          : resetToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthResultModelImplCopyWith<$Res>
    implements $AuthResultModelCopyWith<$Res> {
  factory _$$AuthResultModelImplCopyWith(_$AuthResultModelImpl value,
          $Res Function(_$AuthResultModelImpl) then) =
      __$$AuthResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? token,
      String? userId,
      String? name,
      String? foundId,
      String? profileImageUrl,
      String? resetToken});
}

/// @nodoc
class __$$AuthResultModelImplCopyWithImpl<$Res>
    extends _$AuthResultModelCopyWithImpl<$Res, _$AuthResultModelImpl>
    implements _$$AuthResultModelImplCopyWith<$Res> {
  __$$AuthResultModelImplCopyWithImpl(
      _$AuthResultModelImpl _value, $Res Function(_$AuthResultModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = freezed,
    Object? userId = freezed,
    Object? name = freezed,
    Object? foundId = freezed,
    Object? profileImageUrl = freezed,
    Object? resetToken = freezed,
  }) {
    return _then(_$AuthResultModelImpl(
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      foundId: freezed == foundId
          ? _value.foundId
          : foundId // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      resetToken: freezed == resetToken
          ? _value.resetToken
          : resetToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResultModelImpl implements _AuthResultModel {
  const _$AuthResultModelImpl(
      {this.token,
      this.userId,
      this.name,
      this.foundId,
      this.profileImageUrl,
      this.resetToken});

  factory _$AuthResultModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResultModelImplFromJson(json);

// 로그인/인증 성공 시
  @override
  final String? token;
  @override
  final String? userId;
// 아이디 찾기 성공 시
  @override
  final String? name;
  @override
  final String? foundId;
  @override
  final String? profileImageUrl;
// 비밀번호 찾기 성공 시
  @override
  final String? resetToken;

  @override
  String toString() {
    return 'AuthResultModel(token: $token, userId: $userId, name: $name, foundId: $foundId, profileImageUrl: $profileImageUrl, resetToken: $resetToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResultModelImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.foundId, foundId) || other.foundId == foundId) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.resetToken, resetToken) ||
                other.resetToken == resetToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, token, userId, name, foundId, profileImageUrl, resetToken);

  /// Create a copy of AuthResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResultModelImplCopyWith<_$AuthResultModelImpl> get copyWith =>
      __$$AuthResultModelImplCopyWithImpl<_$AuthResultModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResultModelImplToJson(
      this,
    );
  }
}

abstract class _AuthResultModel implements AuthResultModel {
  const factory _AuthResultModel(
      {final String? token,
      final String? userId,
      final String? name,
      final String? foundId,
      final String? profileImageUrl,
      final String? resetToken}) = _$AuthResultModelImpl;

  factory _AuthResultModel.fromJson(Map<String, dynamic> json) =
      _$AuthResultModelImpl.fromJson;

// 로그인/인증 성공 시
  @override
  String? get token;
  @override
  String? get userId; // 아이디 찾기 성공 시
  @override
  String? get name;
  @override
  String? get foundId;
  @override
  String? get profileImageUrl; // 비밀번호 찾기 성공 시
  @override
  String? get resetToken;

  /// Create a copy of AuthResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResultModelImplCopyWith<_$AuthResultModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
