// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliveryorderthailists.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryOrderThailists _$DeliveryOrderThailistsFromJson(
        Map<String, dynamic> json) =>
    DeliveryOrderThailists(
      (json['id'] as num?)?.toInt(),
      (json['delivery_order_thai_id'] as num?)?.toInt(),
      (json['delivery_order_id'] as num?)?.toInt(),
      (json['delivery_order_list_id'] as num?)?.toInt(),
      (json['delivery_order_list_item_id'] as num?)?.toInt(),
      (json['order_id'] as num?)?.toInt(),
      (json['member_id'] as num?)?.toInt(),
      (json['member_address_id'] as num?)?.toInt(),
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$DeliveryOrderThailistsToJson(
        DeliveryOrderThailists instance) =>
    <String, dynamic>{
      'id': instance.id,
      'delivery_order_thai_id': instance.delivery_order_thai_id,
      'delivery_order_id': instance.delivery_order_id,
      'delivery_order_list_id': instance.delivery_order_list_id,
      'delivery_order_list_item_id': instance.delivery_order_list_item_id,
      'order_id': instance.order_id,
      'member_id': instance.member_id,
      'member_address_id': instance.member_address_id,
      'created_at': instance.created_at?.toIso8601String(),
      'updated_at': instance.updated_at?.toIso8601String(),
    };
