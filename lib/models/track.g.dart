// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Track _$TrackFromJson(Map<String, dynamic> json) => Track(
      (json['id'] as num?)?.toInt(),
      (json['delivery_order_id'] as num?)?.toInt(),
      (json['track_id'] as num?)?.toInt(),
      json['track_no'] as String?,
      (json['delivery_order_lists'] as List<dynamic>?)
          ?.map((e) => DeliveryOrderLists.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'id': instance.id,
      'delivery_order_id': instance.delivery_order_id,
      'track_id': instance.track_id,
      'track_no': instance.track_no,
      'delivery_order_lists': instance.delivery_order_lists,
    };
