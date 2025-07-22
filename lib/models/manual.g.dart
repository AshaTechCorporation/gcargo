// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Manual _$ManualFromJson(Map<String, dynamic> json) => Manual(
  (json['id'] as num?)?.toInt(),
  json['code'] as String?,
  (json['category_member_manual_id'] as num?)?.toInt(),
  json['name'] as String?,
  json['description'] as String?,
  json['image'] as String?,
  (json['No'] as num?)?.toInt(),
  (json['category_newss_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$ManualToJson(Manual instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'category_member_manual_id': instance.category_member_manual_id,
  'category_newss_id': instance.category_newss_id,
  'name': instance.name,
  'description': instance.description,
  'image': instance.image,
  'No': instance.No,
};
