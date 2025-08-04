// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billlistsgrouped.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillListsGrouped _$BillListsGroupedFromJson(Map<String, dynamic> json) =>
    BillListsGrouped(
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
      (json['pallet_id'] as num?)?.toInt(),
      (json['sack_id'] as num?)?.toInt(),
      (json['packing_list_id'] as num?)?.toInt(),
      json['submit_account_system'] as String?,
      json['state'] as String?,
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      json['product_type'] == null
          ? null
          : ProductType.fromJson(json['product_type'] as Map<String, dynamic>),
      (json['delivery_order_thai_lists'] as List<dynamic>?)
          ?.map(
              (e) => DeliveryOrderThailists.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['delivery_order'] == null
          ? null
          : DeliveryOrder.fromJson(
              json['delivery_order'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BillListsGroupedToJson(BillListsGrouped instance) =>
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
      'pallet_id': instance.pallet_id,
      'sack_id': instance.sack_id,
      'packing_list_id': instance.packing_list_id,
      'submit_account_system': instance.submit_account_system,
      'state': instance.state,
      'created_at': instance.created_at?.toIso8601String(),
      'updated_at': instance.updated_at?.toIso8601String(),
      'product_type': instance.product_type,
      'delivery_order_thai_lists': instance.delivery_order_thai_lists,
      'delivery_order': instance.delivery_order,
    };
