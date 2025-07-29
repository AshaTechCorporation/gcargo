// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallettrans.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletTrans _$WalletTransFromJson(Map<String, dynamic> json) => WalletTrans(
      (json['id'] as num?)?.toInt(),
      json['code'] as String?,
      (json['No'] as num?)?.toInt(),
      json['amount'] as String?,
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      json['detail'] as String?,
      json['in_from'] as String?,
      (json['member_id'] as num?)?.toInt(),
      json['out_to'] as String?,
      json['reference_id'] as String?,
      json['status'] as String?,
      json['type'] as String?,
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      json['member'] == null
          ? null
          : User.fromJson(json['member'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WalletTransToJson(WalletTrans instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'member_id': instance.member_id,
      'in_from': instance.in_from,
      'out_to': instance.out_to,
      'reference_id': instance.reference_id,
      'detail': instance.detail,
      'amount': instance.amount,
      'type': instance.type,
      'status': instance.status,
      'created_at': instance.created_at?.toIso8601String(),
      'updated_at': instance.updated_at?.toIso8601String(),
      'No': instance.No,
      'member': instance.member,
    };
