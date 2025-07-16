// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'importorderlists.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportOrderLists _$ImportOrderListsFromJson(Map<String, dynamic> json) =>
    ImportOrderLists(
      (json['id'] as num?)?.toInt(),
      (json['import_product_order_id'] as num?)?.toInt(),
      (json['product_type_id'] as num?)?.toInt(),
      json['product_name'] as String?,
      json['product_image'] as String?,
      (json['standard_size_id'] as num?)?.toInt(),
      (json['delivery_order_tracking_id'] as num?)?.toInt(),
      json['weight'] as String?,
      json['width'] as String?,
      json['height'] as String?,
      json['long'] as String?,
      (json['qty'] as num?)?.toInt(),
      (json['qty_box'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ImportOrderListsToJson(ImportOrderLists instance) =>
    <String, dynamic>{
      'id': instance.id,
      'import_product_order_id': instance.import_product_order_id,
      'product_type_id': instance.product_type_id,
      'product_name': instance.product_name,
      'product_image': instance.product_image,
      'standard_size_id': instance.standard_size_id,
      'delivery_order_tracking_id': instance.delivery_order_tracking_id,
      'weight': instance.weight,
      'width': instance.width,
      'height': instance.height,
      'long': instance.long,
      'qty': instance.qty,
      'qty_box': instance.qty_box,
    };
