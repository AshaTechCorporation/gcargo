// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shipping _$ShippingFromJson(Map<String, dynamic> json) => Shipping(
  (json['id'] as num?)?.toInt(),
  json['code'] as String?,
  (json['member_id'] as num?)?.toInt(),
  json['address'] as String?,
  json['province'] as String?,
  json['district'] as String?,
  json['sub_district'] as String?,
  json['postal_code'] as String?,
  json['latitude'] as String?,
  json['longitude'] as String?,
  json['contact_name'] as String?,
  json['contact_phone'] as String?,
  json['contact_phone2'] as String?,
  json['first'] as String?,
);

Map<String, dynamic> _$ShippingToJson(Shipping instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'member_id': instance.member_id,
  'address': instance.address,
  'province': instance.province,
  'district': instance.district,
  'sub_district': instance.sub_district,
  'postal_code': instance.postal_code,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'contact_name': instance.contact_name,
  'contact_phone': instance.contact_phone,
  'contact_phone2': instance.contact_phone2,
  'first': instance.first,
};
