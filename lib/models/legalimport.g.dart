// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legalimport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LegalImport _$LegalImportFromJson(Map<String, dynamic> json) => LegalImport(
  (json['delivery_orders'] as List<dynamic>?)
      ?.map((e) => OrdersPageNew.fromJson(e as Map<String, dynamic>))
      .toList(),
  json['status'] as String?,
  (json['import_orders'] as List<dynamic>?)
      ?.map((e) => Importorders.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LegalImportToJson(LegalImport instance) =>
    <String, dynamic>{
      'status': instance.status,
      'delivery_orders': instance.delivery_orders,
      'import_orders': instance.import_orders,
    };
