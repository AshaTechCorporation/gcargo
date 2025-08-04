// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tegaboutus.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tegaboutus _$TegaboutusFromJson(Map<String, dynamic> json) => Tegaboutus(
      id: (json['id'] as num?)?.toInt(),
      detail: json['detail'] as String?,
      title_box: json['title_box'] as String?,
      body_box: json['body_box'] as String?,
      footer_box: json['footer_box'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      wechat: json['wechat'] as String?,
      line: json['line'] as String?,
      facebook: json['facebook'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$TegaboutusToJson(Tegaboutus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'detail': instance.detail,
      'title_box': instance.title_box,
      'body_box': instance.body_box,
      'footer_box': instance.footer_box,
      'phone': instance.phone,
      'email': instance.email,
      'wechat': instance.wechat,
      'line': instance.line,
      'facebook': instance.facebook,
      'status': instance.status,
    };
