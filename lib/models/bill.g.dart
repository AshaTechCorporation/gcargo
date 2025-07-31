// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bill _$BillFromJson(Map<String, dynamic> json) => Bill(
      (json['id'] as num?)?.toInt(),
      json['code'] as String?,
      json['in_thai_date'] as String?,
      (json['member_id'] as num?)?.toInt(),
      (json['member_address_id'] as num?)?.toInt(),
      json['total_amount'] as String?,
      json['total_vat'] as String?,
      json['notes'] as String?,
      json['status'] as String?,
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      json['member_address'] == null
          ? null
          : MemberAddress.fromJson(
              json['member_address'] as Map<String, dynamic>),
      (json['bill_lists_grouped'] as List<dynamic>?)
          ?.map((e) => BillListsGrouped.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BillToJson(Bill instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'in_thai_date': instance.in_thai_date,
      'member_id': instance.member_id,
      'member_address_id': instance.member_address_id,
      'total_amount': instance.total_amount,
      'total_vat': instance.total_vat,
      'notes': instance.notes,
      'status': instance.status,
      'created_at': instance.created_at?.toIso8601String(),
      'updated_at': instance.updated_at?.toIso8601String(),
      'member_address': instance.member_address,
      'bill_lists_grouped': instance.bill_lists_grouped,
    };
