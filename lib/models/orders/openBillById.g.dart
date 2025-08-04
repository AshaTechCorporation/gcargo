// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openBillById.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenBillById _$OpenBillByIdFromJson(Map<String, dynamic> json) => OpenBillById(
      (json['id'] as num?)?.toInt(),
      (json['billing_id'] as num?)?.toInt(),
      (json['delivery_order_thai_list_id'] as num?)?.toInt(),
      (json['delivery_order_thai_id'] as num?)?.toInt(),
      json['amount'] as String?,
      json['status'] as String?,
      (json['delivery_order_list'] as List<dynamic>?)
          ?.map((e) => DeliveryOrderLists.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OpenBillByIdToJson(OpenBillById instance) =>
    <String, dynamic>{
      'id': instance.id,
      'billing_id': instance.billing_id,
      'delivery_order_thai_list_id': instance.delivery_order_thai_list_id,
      'delivery_order_thai_id': instance.delivery_order_thai_id,
      'amount': instance.amount,
      'status': instance.status,
      'delivery_order_list': instance.delivery_order_list,
    };
