// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Store _$StoreFromJson(Map<String, dynamic> json) => Store(
  (json['id'] as num?)?.toInt(),
  json['code'] as String?,
  json['name'] as String?,
  json['name_ch'] as String?,
  json['name_en'] as String?,
  json['description'] as String?,
  json['image'] as String?,
  json['address'] as String?,
  json['address_ch'] as String?,
  json['address_en'] as String?,
  json['phone'] as String?,
  json['map'] as String?,
  json['type'] as String?,
  json['status'] as String?,
);

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'name_ch': instance.name_ch,
  'name_en': instance.name_en,
  'description': instance.description,
  'image': instance.image,
  'address': instance.address,
  'address_ch': instance.address_ch,
  'address_en': instance.address_en,
  'phone': instance.phone,
  'map': instance.map,
  'type': instance.type,
  'status': instance.status,
};
