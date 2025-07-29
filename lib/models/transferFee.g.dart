// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transferFee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferFee _$TransferFeeFromJson(Map<String, dynamic> json) => TransferFee(
      (json['id'] as num?)?.toInt(),
      json['transfer_fee'] as String?,
      json['alipay_fee'] as String?,
      json['account_open_fee'] as String?,
    );

Map<String, dynamic> _$TransferFeeToJson(TransferFee instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transfer_fee': instance.transfer_fee,
      'alipay_fee': instance.alipay_fee,
      'account_open_fee': instance.account_open_fee,
    };
