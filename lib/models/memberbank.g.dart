// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memberbank.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberBank _$MemberBankFromJson(Map<String, dynamic> json) => MemberBank(
      (json['id'] as num?)?.toInt(),
      json['code'] as String?,
      (json['member_id'] as num?)?.toInt(),
      json['name'] as String?,
      json['description'] as String?,
      json['image'] as String?,
      json['status'] as String?,
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$MemberBankToJson(MemberBank instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'member_id': instance.member_id,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'status': instance.status,
      'created_at': instance.created_at?.toIso8601String(),
      'updated_at': instance.updated_at?.toIso8601String(),
    };
