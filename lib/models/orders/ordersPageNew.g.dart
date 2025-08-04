// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordersPageNew.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrdersPageNew _$OrdersPageNewFromJson(Map<String, dynamic> json) =>
    OrdersPageNew(
      json['date'] as String?,
      json['member_id'] as String?,
      json['po_no'] as String?,
      json['payment_term'] as String?,
      json['note'] as String?,
      (json['member_address_id'] as num?)?.toInt(),
      json['status'] as String?,
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      json['member'] == null
          ? null
          : User.fromJson(json['member'] as Map<String, dynamic>),
      json['shipment_by'] as String?,
      (json['delivery_order_lists'] as List<dynamic>?)
          ?.map((e) => DeliveryOrderLists.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['code'] as String?,
      (json['id'] as num?)?.toInt(),
      (json['order_id'] as num?)?.toInt(),
      json['driver_name'] as String?,
      json['driver_phone'] as String?,
      json['store'] == null
          ? null
          : ServiceTransporter.fromJson(json['store'] as Map<String, dynamic>),
      json['product_type'] == null
          ? null
          : ServiceTransporter.fromJson(
              json['product_type'] as Map<String, dynamic>),
      json['import_po'] == null
          ? null
          : ImportPo.fromJson(json['import_po'] as Map<String, dynamic>),
      json['order'] == null
          ? null
          : ShippingDeilvery.fromJson(json['order'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrdersPageNewToJson(OrdersPageNew instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'po_no': instance.po_no,
      'order_id': instance.order_id,
      'date': instance.date,
      'driver_name': instance.driver_name,
      'driver_phone': instance.driver_phone,
      'member_id': instance.member_id,
      'payment_term': instance.payment_term,
      'note': instance.note,
      'shipment_by': instance.shipment_by,
      'member_address_id': instance.member_address_id,
      'status': instance.status,
      'created_at': instance.created_at?.toIso8601String(),
      'member': instance.member,
      'delivery_order_lists': instance.delivery_order_lists,
      'store': instance.store,
      'product_type': instance.product_type,
      'import_po': instance.import_po,
      'order': instance.order,
    };
