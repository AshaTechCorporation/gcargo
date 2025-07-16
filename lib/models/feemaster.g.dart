// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feemaster.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feemaster _$FeemasterFromJson(Map<String, dynamic> json) => Feemaster(
  (json['id'] as num?)?.toInt(),
  json['code'] as String?,
  (json['category_fee_master_id'] as num?)?.toInt(),
  json['name'] as String?,
  (json['price'] as num?)?.toInt(),
  json['check'] as String?,
  json['category_fee_master'] == null
      ? null
      : CategoryFeemaster.fromJson(
        json['category_fee_master'] as Map<String, dynamic>,
      ),
);

Map<String, dynamic> _$FeemasterToJson(Feemaster instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'category_fee_master_id': instance.category_fee_master_id,
  'name': instance.name,
  'price': instance.price,
  'check': instance.check,
  'category_fee_master': instance.category_fee_master,
};
