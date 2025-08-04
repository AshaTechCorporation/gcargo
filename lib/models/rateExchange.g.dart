// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rateExchange.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RateExchange _$RateExchangeFromJson(Map<String, dynamic> json) => RateExchange(
      json['base'] as String?,
      json['target'] as String?,
      json['rate'] as String?,
      json['fetched_at'] == null
          ? null
          : DateTime.parse(json['fetched_at'] as String),
    );

Map<String, dynamic> _$RateExchangeToJson(RateExchange instance) =>
    <String, dynamic>{
      'base': instance.base,
      'target': instance.target,
      'rate': instance.rate,
      'fetched_at': instance.fetched_at?.toIso8601String(),
    };
