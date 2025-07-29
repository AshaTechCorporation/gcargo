// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rateShip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RateShip _$RateShipFromJson(Map<String, dynamic> json) => RateShip(
      (json['id'] as num?)?.toInt(),
      json['code'] as String?,
      json['vehicle'] as String?,
      json['type'] as String?,
      json['name'] as String?,
      json['option'] as String?,
      json['kg'] as String?,
      json['cbm'] as String?,
      json['status'] as String?,
    );

Map<String, dynamic> _$RateShipToJson(RateShip instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'vehicle': instance.vehicle,
      'type': instance.type,
      'name': instance.name,
      'option': instance.option,
      'kg': instance.kg,
      'cbm': instance.cbm,
      'status': instance.status,
    };
