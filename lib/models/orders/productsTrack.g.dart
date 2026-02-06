// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'productsTrack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductsTrack _$ProductsTrackFromJson(Map<String, dynamic> json) => ProductsTrack(
  json['track_ecommerce_no'] as String?,
  json['po_no'] as String?,
  json['product_code'] as String?,
  json['product_name'] as String?,
  json['product_url'] as String?,
  json['product_image'] as String?,
  json['product_category'] as String?,
  json['product_store_type'] as String?,
  json['product_note'] as String?,
  json['product_price'] as String?,
  json['product_real_price'] as String?,
  (json['product_qty'] as num?)?.toInt(),
  (json['add_on_services'] as List<dynamic>?)?.map((e) => PartAddOnTrack.fromJson(e as Map<String, dynamic>)).toList(),
  (json['options'] as List<dynamic>?)?.map((e) => OptionsOrdersTeack.fromJson(e as Map<String, dynamic>)).toList(),
);

Map<String, dynamic> _$ProductsTrackToJson(ProductsTrack instance) => <String, dynamic>{
  'track_ecommerce_no': instance.track_ecommerce_no,
  'po_no': instance.po_no,
  'product_code': instance.product_code,
  'product_name': instance.product_name,
  'product_url': instance.product_url,
  'product_image': instance.product_image,
  'product_category': instance.product_category,
  'product_store_type': instance.product_store_type,
  'product_note': instance.product_note,
  'product_price': instance.product_price,
  'product_real_price': instance.product_real_price,
  'product_qty': instance.product_qty,
  'add_on_services': instance.add_on_services,
  'options': instance.options,
};
