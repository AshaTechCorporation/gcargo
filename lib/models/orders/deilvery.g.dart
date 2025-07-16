// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deilvery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Deilvery _$DeilveryFromJson(Map<String, dynamic> json) => Deilvery(
  (json['id'] as num?)?.toInt(),
  json['track_ecommerce_no'] as String?,
  (json['product_draft_id'] as num?)?.toInt(),
  (json['product_type_id'] as num?)?.toInt(),
  json['product_shop'] as String?,
  json['product_code'] as String?,
  json['product_name'] as String?,
  json['product_url'] as String?,
  json['product_image'] as String?,
  json['product_category'] as String?,
  json['product_price'] as String?,
  json['product_store_type'] as String?,
  (json['product_qty'] as num?)?.toInt(),
  json['product_real_price'] as String?,
  (json['standard_size_id'] as num?)?.toInt(),
  (json['weight'] as num?)?.toDouble(),
  (json['width'] as num?)?.toDouble(),
  (json['height'] as num?)?.toDouble(),
  (json['long'] as num?)?.toDouble(),
  (json['qty'] as num?)?.toInt(),
  (json['qty_box'] as num?)?.toInt(),
);

Map<String, dynamic> _$DeilveryToJson(Deilvery instance) => <String, dynamic>{
  'id': instance.id,
  'track_ecommerce_no': instance.track_ecommerce_no,
  'product_draft_id': instance.product_draft_id,
  'product_type_id': instance.product_type_id,
  'product_shop': instance.product_shop,
  'product_code': instance.product_code,
  'product_name': instance.product_name,
  'product_url': instance.product_url,
  'product_image': instance.product_image,
  'product_category': instance.product_category,
  'product_store_type': instance.product_store_type,
  'product_price': instance.product_price,
  'product_qty': instance.product_qty,
  'product_real_price': instance.product_real_price,
  'standard_size_id': instance.standard_size_id,
  'weight': instance.weight,
  'width': instance.width,
  'height': instance.height,
  'long': instance.long,
  'qty': instance.qty,
  'qty_box': instance.qty_box,
};
