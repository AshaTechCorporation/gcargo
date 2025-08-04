// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Products _$ProductsFromJson(Map<String, dynamic> json) => Products(
      json['product_shop'] as String?,
      json['product_code'] as String?,
      json['product_name'] as String?,
      json['product_url'] as String?,
      json['product_image'] as String?,
      json['product_category'] as String?,
      json['product_store_type'] as String?,
      json['product_note'] as String?,
      json['product_price'] as String?,
      json['product_qty'] as String?,
      (json['add_on_services'] as List<dynamic>?)
          ?.map((e) => PartService.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['options'] as List<dynamic>?)
          ?.map((e) => OptionsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProductsToJson(Products instance) => <String, dynamic>{
      'product_shop': instance.product_shop,
      'product_code': instance.product_code,
      'product_name': instance.product_name,
      'product_url': instance.product_url,
      'product_image': instance.product_image,
      'product_category': instance.product_category,
      'product_store_type': instance.product_store_type,
      'product_note': instance.product_note,
      'product_price': instance.product_price,
      'product_qty': instance.product_qty,
      'add_on_services': instance.add_on_services,
      'options': instance.options,
    };
