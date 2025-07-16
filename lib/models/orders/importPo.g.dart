// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'importPo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportPo _$ImportPoFromJson(Map<String, dynamic> json) => ImportPo(
  json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  (json['id'] as num?)?.toInt(),
  (json['member_id'] as num?)?.toInt(),
  (json['delivery_order_id'] as num?)?.toInt(),
  json['status'] as String?,
);

Map<String, dynamic> _$ImportPoToJson(ImportPo instance) => <String, dynamic>{
  'id': instance.id,
  'member_id': instance.member_id,
  'delivery_order_id': instance.delivery_order_id,
  'status': instance.status,
  'created_at': instance.created_at?.toIso8601String(),
  'updated_at': instance.updated_at?.toIso8601String(),
};
