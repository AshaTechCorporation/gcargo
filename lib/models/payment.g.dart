// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
      (json['id'] as num?)?.toInt(),
      json['code'] as String?,
      (json['member_id'] as num?)?.toInt(),
      json['transaction'] as String?,
      json['amount'] as String?,
      json['fee'] as String?,
      json['image_qr_code'] as String?,
      json['image'] as String?,
      json['image_url'] as String?,
      json['image_slip'] as String?,
      json['image_slip_url'] as String?,
      json['phone'] as String?,
      json['note'] as String?,
      json['status'] as String?,
      json['transfer_at'] == null
          ? null
          : DateTime.parse(json['transfer_at'] as String),
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      (json['No'] as num?)?.toInt(),
      json['member'] == null
          ? null
          : User.fromJson(json['member'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'member_id': instance.member_id,
      'transaction': instance.transaction,
      'amount': instance.amount,
      'fee': instance.fee,
      'image_qr_code': instance.image_qr_code,
      'image': instance.image,
      'image_url': instance.image_url,
      'image_slip': instance.image_slip,
      'image_slip_url': instance.image_slip_url,
      'phone': instance.phone,
      'note': instance.note,
      'status': instance.status,
      'transfer_at': instance.transfer_at?.toIso8601String(),
      'created_at': instance.created_at?.toIso8601String(),
      'updated_at': instance.updated_at?.toIso8601String(),
      'No': instance.No,
      'member': instance.member,
    };
