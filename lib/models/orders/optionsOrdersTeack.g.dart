// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optionsOrdersTeack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionsOrdersTeack _$OptionsOrdersTeackFromJson(Map<String, dynamic> json) =>
    OptionsOrdersTeack(
      (json['id'] as num?)?.toInt(),
      (json['order_id'] as num?)?.toInt(),
      (json['order_list_id'] as num?)?.toInt(),
      json['option_name'] as String?,
      json['option_image'] as String?,
      json['option_note'] as String?,
    );

Map<String, dynamic> _$OptionsOrdersTeackToJson(OptionsOrdersTeack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.order_id,
      'order_list_id': instance.order_list_id,
      'option_name': instance.option_name,
      'option_image': instance.option_image,
      'option_note': instance.option_note,
    };
