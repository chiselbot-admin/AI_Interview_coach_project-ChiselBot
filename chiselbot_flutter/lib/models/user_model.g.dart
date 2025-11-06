// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      email: json['email'] as String,
      password: json['password'] as String,
      phoneNumber: json['phoneNumber'] as String,
      name: json['name'] as String?,
      userId: json['userId'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'phoneNumber': instance.phoneNumber,
      'name': instance.name,
      'userId': instance.userId,
      'profileImageUrl': instance.profileImageUrl,
    };
