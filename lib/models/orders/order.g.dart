// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  (json['id'] as num?)?.toInt(),
  json['code'] as String?,
  (json['member_id'] as num?)?.toInt(),
  (json['member_address_id'] as num?)?.toInt(),
  json['shipping_type'] as String?,
  json['payment_term'] as String?,
  json['date'] as String?,
  json['total_price'] as String?,
  json['note'] as String?,
  json['status'] as String?,
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'member_id': instance.member_id,
  'member_address_id': instance.member_address_id,
  'shipping_type': instance.shipping_type,
  'payment_term': instance.payment_term,
  'date': instance.date,
  'total_price': instance.total_price,
  'note': instance.note,
  'status': instance.status,
};
