// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partAddOnTrack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartAddOnTrack _$PartAddOnTrackFromJson(Map<String, dynamic> json) =>
    PartAddOnTrack(
      (json['id'] as num?)?.toInt(),
      (json['order_id'] as num?)?.toInt(),
      (json['order_list_id'] as num?)?.toInt(),
      (json['add_on_service_id'] as num?)?.toInt(),
      (json['add_on_service_price'] as num?)?.toInt(),
      json['add_on_service'] == null
          ? null
          : ServiceTransporterById.fromJson(
              json['add_on_service'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PartAddOnTrackToJson(PartAddOnTrack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.order_id,
      'order_list_id': instance.order_list_id,
      'add_on_service_id': instance.add_on_service_id,
      'add_on_service_price': instance.add_on_service_price,
      'add_on_service': instance.add_on_service,
    };
