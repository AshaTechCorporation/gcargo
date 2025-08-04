// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partService.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartService _$PartServiceFromJson(Map<String, dynamic> json) => PartService(
      (json['add_on_service_id'] as num?)?.toInt(),
      (json['add_on_service_price'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PartServiceToJson(PartService instance) =>
    <String, dynamic>{
      'add_on_service_id': instance.add_on_service_id,
      'add_on_service_price': instance.add_on_service_price,
    };
