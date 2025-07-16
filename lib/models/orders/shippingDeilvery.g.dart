// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shippingDeilvery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShippingDeilvery _$ShippingDeilveryFromJson(Map<String, dynamic> json) =>
    ShippingDeilvery(
      (json['id'] as num?)?.toInt(),
      (json['member_address_id'] as num?)?.toInt(),
      (json['member_id'] as num?)?.toInt(),
      json['code'] as String?,
      json['shipping_type'] as String?,
      json['payment_term'] as String?,
      json['date'] as String?,
      json['status'] as String?,
      json['total_price'] as String?,
      json['note'] as String?,
      json['deposit_fee'] as String?,
      json['exchange_rate'] as String?,
      json['china_shipping_fee'] as String?,
      (json['order_lists'] as List<dynamic>?)
          ?.map((e) => Deilvery.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ShippingDeilveryToJson(ShippingDeilvery instance) =>
    <String, dynamic>{
      'id': instance.id,
      'member_address_id': instance.member_address_id,
      'member_id': instance.member_id,
      'code': instance.code,
      'shipping_type': instance.shipping_type,
      'payment_term': instance.payment_term,
      'date': instance.date,
      'status': instance.status,
      'total_price': instance.total_price,
      'note': instance.note,
      'deposit_fee': instance.deposit_fee,
      'exchange_rate': instance.exchange_rate,
      'china_shipping_fee': instance.china_shipping_fee,
      'order_lists': instance.order_lists,
    };
