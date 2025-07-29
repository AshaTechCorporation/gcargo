// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serviceTransporterById.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceTransporterById _$ServiceTransporterByIdFromJson(
        Map<String, dynamic> json) =>
    ServiceTransporterById(
      (json['id'] as num?)?.toInt(),
      json['code'] as String?,
      (json['service_id'] as num?)?.toInt(),
      json['name'] as String?,
      json['description'] as String?,
      json['image'] as String?,
      (json['standard_price'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ServiceTransporterByIdToJson(
        ServiceTransporterById instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'service_id': instance.service_id,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'standard_price': instance.standard_price,
    };
