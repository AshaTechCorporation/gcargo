// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliveryorder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryOrder _$DeliveryOrderFromJson(Map<String, dynamic> json) =>
    DeliveryOrder(
      (json['id'] as num?)?.toInt(),
      json['code'] as String?,
      json['member_id'] as String?,
      (json['order_id'] as num?)?.toInt(),
      json['date'] as String?,
      json['driver_name'] as String?,
      json['driver_phone'] as String?,
      json['note'] as String?,
      json['status'] as String?,
      json['order'] == null
          ? null
          : Order.fromJson(json['order'] as Map<String, dynamic>),
      json['track'] == null
          ? null
          : Track.fromJson(json['track'] as Map<String, dynamic>),
      (json['delivery_order_lists'] as List<dynamic>?)
          ?.map((e) => DeliveryOrderLists.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeliveryOrderToJson(DeliveryOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'member_id': instance.member_id,
      'order_id': instance.order_id,
      'date': instance.date,
      'driver_name': instance.driver_name,
      'driver_phone': instance.driver_phone,
      'note': instance.note,
      'status': instance.status,
      'order': instance.order,
      'track': instance.track,
      'delivery_order_lists': instance.delivery_order_lists,
    };
