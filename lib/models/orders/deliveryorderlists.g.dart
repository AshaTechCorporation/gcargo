// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliveryorderlists.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryOrderLists _$DeliveryOrderListsFromJson(Map<String, dynamic> json) =>
    DeliveryOrderLists(
      (json['id'] as num?)?.toInt(),
      json['code'] as String?,
      json['barcode'] as String?,
      (json['product_draft_id'] as num?)?.toInt(),
      (json['delivery_order_id'] as num?)?.toInt(),
      (json['delivery_order_tracking_id'] as num?)?.toInt(),
      (json['product_type_id'] as num?)?.toInt(),
      json['product_name'] as String?,
      json['product_image'] as String?,
      (json['standard_size_id'] as num?)?.toInt(),
      json['weight'] as String?,
      json['width'] as String?,
      json['height'] as String?,
      json['long'] as String?,
      (json['qty'] as num?)?.toInt(),
      (json['qty_box'] as num?)?.toInt(),
      (json['delivery_order_thai_lists'] as List<dynamic>?)
          ?.map((e) => OpenBillById.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['delivery_order'] == null
          ? null
          : OrdersPageNew.fromJson(
              json['delivery_order'] as Map<String, dynamic>),
      json['product_type'] == null
          ? null
          : ServiceTransporter.fromJson(
              json['product_type'] as Map<String, dynamic>),
      selected: json['selected'] as bool? ?? false,
      selected2: json['selected2'] as bool? ?? false,
    );

Map<String, dynamic> _$DeliveryOrderListsToJson(DeliveryOrderLists instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'barcode': instance.barcode,
      'product_draft_id': instance.product_draft_id,
      'delivery_order_id': instance.delivery_order_id,
      'delivery_order_tracking_id': instance.delivery_order_tracking_id,
      'product_type_id': instance.product_type_id,
      'product_name': instance.product_name,
      'product_image': instance.product_image,
      'standard_size_id': instance.standard_size_id,
      'weight': instance.weight,
      'width': instance.width,
      'height': instance.height,
      'long': instance.long,
      'qty': instance.qty,
      'qty_box': instance.qty_box,
      'delivery_order_thai_lists': instance.delivery_order_thai_lists,
      'delivery_order': instance.delivery_order,
      'product_type': instance.product_type,
      'selected': instance.selected,
      'selected2': instance.selected2,
    };
