// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categoryfeemaster.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryFeemaster _$CategoryFeemasterFromJson(Map<String, dynamic> json) =>
    CategoryFeemaster(
      (json['id'] as num?)?.toInt(),
      json['code'] as String?,
      json['type'] as String?,
      json['name'] as String?,
    );

Map<String, dynamic> _$CategoryFeemasterToJson(CategoryFeemaster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'type': instance.type,
      'name': instance.name,
    };
