// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordersPage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrdersPage _$OrdersPageFromJson(Map<String, dynamic> json) => OrdersPage(
      json['date'] as String?,
      json['total_price'] as String?,
      (json['member_id'] as num?)?.toInt(),
      json['shipping_type'] as String?,
      json['payment_term'] as String?,
      json['note'] as String?,
      (json['member_address_id'] as num?)?.toInt(),
      json['status'] as String?,
      json['deposit_fee'] as String?,
      json['exchange_rate'] as String?,
      json['china_shipping_fee'] as String?,
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      json['member'] == null
          ? null
          : User.fromJson(json['member'] as Map<String, dynamic>),
      (json['order_lists'] as List<dynamic>?)
          ?.map((e) => ProductsTrack.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['orders'] as List<dynamic>?)
          ?.map((e) => OrdersPage.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['delivery_order_lists'] as List<dynamic>?)
          ?.map((e) => DeliveryOrderLists.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['code'] as String?,
      (json['id'] as num?)?.toInt(),
      (json['delivery_orders'] as List<dynamic>?)
          ?.map((e) => OrdersPageNew.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrdersPageToJson(OrdersPage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'date': instance.date,
      'shipping_type': instance.shipping_type,
      'total_price': instance.total_price,
      'member_id': instance.member_id,
      'payment_term': instance.payment_term,
      'note': instance.note,
      'member_address_id': instance.member_address_id,
      'status': instance.status,
      'deposit_fee': instance.deposit_fee,
      'exchange_rate': instance.exchange_rate,
      'china_shipping_fee': instance.china_shipping_fee,
      'created_at': instance.created_at?.toIso8601String(),
      'member': instance.member,
      'order_lists': instance.order_lists,
      'orders': instance.orders,
      'delivery_order_lists': instance.delivery_order_lists,
      'delivery_orders': instance.delivery_orders,
    };
