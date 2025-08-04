// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'importproductorderlistfees.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportProductOrderlistFees _$ImportProductOrderlistFeesFromJson(
        Map<String, dynamic> json) =>
    ImportProductOrderlistFees(
      (json['id'] as num?)?.toInt(),
      (json['import_product_order_id'] as num?)?.toInt(),
      (json['fee_master_id'] as num?)?.toInt(),
      (json['amount'] as num?)?.toInt(),
      json['status'] as String?,
      json['fee_master'] == null
          ? null
          : Feemaster.fromJson(json['fee_master'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ImportProductOrderlistFeesToJson(
        ImportProductOrderlistFees instance) =>
    <String, dynamic>{
      'id': instance.id,
      'import_product_order_id': instance.import_product_order_id,
      'fee_master_id': instance.fee_master_id,
      'amount': instance.amount,
      'status': instance.status,
      'fee_master': instance.fee_master,
    };
