// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
      (json['id'] as num?)?.toInt(),
      json['code'] as String?,
      (json['member_id'] as num?)?.toInt(),
      json['comp_name'] as String?,
      json['comp_tax'] as String?,
      json['comp_phone'] as String?,
      json['cargo_website'] as String?,
      json['cargo_image'] as String?,
      (json['transport_thai_master_id'] as num?)?.toInt(),
      json['province'] as String?,
      json['district'] as String?,
      json['sub_district'] as String?,
      json['postal_code'] as String?,
      json['latitude'] as String?,
      json['longitude'] as String?,
      json['transport_type'] as String?,
      json['order_quantity_in_thai'] as String?,
      json['order_quantity'] as String?,
      json['have_any_customers'] as String?,
      json['additional_requests'] as String?,
      json['address'] as String?,
      (json['registered'] as num?)?.toInt(),
      json['frequent_importer'] as String?,
    );

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'member_id': instance.member_id,
      'comp_name': instance.comp_name,
      'comp_tax': instance.comp_tax,
      'registered': instance.registered,
      'comp_phone': instance.comp_phone,
      'address': instance.address,
      'cargo_website': instance.cargo_website,
      'cargo_image': instance.cargo_image,
      'transport_thai_master_id': instance.transport_thai_master_id,
      'province': instance.province,
      'district': instance.district,
      'sub_district': instance.sub_district,
      'postal_code': instance.postal_code,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'transport_type': instance.transport_type,
      'order_quantity_in_thai': instance.order_quantity_in_thai,
      'order_quantity': instance.order_quantity,
      'have_any_customers': instance.have_any_customers,
      'additional_requests': instance.additional_requests,
      'frequent_importer': instance.frequent_importer,
    };
