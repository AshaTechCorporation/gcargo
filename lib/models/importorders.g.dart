// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'importorders.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Importorders _$ImportordersFromJson(Map<String, dynamic> json) => Importorders(
  (json['id'] as num?)?.toInt(),
  json['code'] as String?,
  (json['member_id'] as num?)?.toInt(),
  (json['delivery_order_id'] as num?)?.toInt(),
  (json['import_po_id'] as num?)?.toInt(),
  (json['register_importer_id'] as num?)?.toInt(),
  (json['store_id'] as num?)?.toInt(),
  json['note'] as String?,
  json['status'] as String?,
  json['invoice_file'] as String?,
  json['packinglist_file'] as String?,
  json['license_file'] as String?,
  json['total_expenses'] as String?,
  json['file'] as String?,
  json['draft_file'] as String?,
  json['member'] == null
      ? null
      : User.fromJson(json['member'] as Map<String, dynamic>),
  (json['import_order_lists'] as List<dynamic>?)
      ?.map((e) => ImportOrderLists.fromJson(e as Map<String, dynamic>))
      .toList(),
  json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  json['delivery_order'] == null
      ? null
      : DeliveryOrder.fromJson(json['delivery_order'] as Map<String, dynamic>),
  (json['delivery_order_tracks'] as List<dynamic>?)
      ?.map((e) => DeliveryOrderTracks.fromJson(e as Map<String, dynamic>))
      .toList(),
  (json['deliverty_order_lists'] as List<dynamic>?)
      ?.map((e) => DeliveryOrderLists.fromJson(e as Map<String, dynamic>))
      .toList(),
  (json['import_product_order_list_fees'] as List<dynamic>?)
      ?.map(
        (e) => ImportProductOrderlistFees.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  json['store'] == null
      ? null
      : Store.fromJson(json['store'] as Map<String, dynamic>),
  json['register_importer'] == null
      ? null
      : RegisterImporter.fromJson(
        json['register_importer'] as Map<String, dynamic>,
      ),
);

Map<String, dynamic> _$ImportordersToJson(Importorders instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'member_id': instance.member_id,
      'delivery_order_id': instance.delivery_order_id,
      'import_po_id': instance.import_po_id,
      'register_importer_id': instance.register_importer_id,
      'store_id': instance.store_id,
      'note': instance.note,
      'status': instance.status,
      'invoice_file': instance.invoice_file,
      'packinglist_file': instance.packinglist_file,
      'license_file': instance.license_file,
      'total_expenses': instance.total_expenses,
      'file': instance.file,
      'draft_file': instance.draft_file,
      'member': instance.member,
      'import_order_lists': instance.import_order_lists,
      'created_at': instance.created_at?.toIso8601String(),
      'updated_at': instance.updated_at?.toIso8601String(),
      'delivery_order': instance.delivery_order,
      'delivery_order_tracks': instance.delivery_order_tracks,
      'deliverty_order_lists': instance.deliverty_order_lists,
      'import_product_order_list_fees': instance.import_product_order_list_fees,
      'store': instance.store,
      'register_importer': instance.register_importer,
    };
