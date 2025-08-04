// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optionsItem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionsItem _$OptionsItemFromJson(Map<String, dynamic> json) => OptionsItem(
      json['option_name'] as String?,
      json['option_image'] as String?,
      json['option_note'] as String?,
    );

Map<String, dynamic> _$OptionsItemToJson(OptionsItem instance) =>
    <String, dynamic>{
      'option_name': instance.option_name,
      'option_image': instance.option_image,
      'option_note': instance.option_note,
    };
