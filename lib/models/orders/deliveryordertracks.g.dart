// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliveryordertracks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryOrderTracks _$DeliveryOrderTracksFromJson(Map<String, dynamic> json) =>
    DeliveryOrderTracks(
      (json['id'] as num?)?.toInt(),
      (json['delivery_order_id'] as num?)?.toInt(),
      (json['track_id'] as num?)?.toInt(),
      json['track_no'] as String?,
    );

Map<String, dynamic> _$DeliveryOrderTracksToJson(
        DeliveryOrderTracks instance) =>
    <String, dynamic>{
      'id': instance.id,
      'delivery_order_id': instance.delivery_order_id,
      'track_id': instance.track_id,
      'track_no': instance.track_no,
    };
