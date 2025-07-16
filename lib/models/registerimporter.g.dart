// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registerimporter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterImporter _$RegisterImporterFromJson(Map<String, dynamic> json) =>
    RegisterImporter(
      (json['id'] as num?)?.toInt(),
      json['code'] as String?,
      json['comp_name'] as String?,
      json['comp_tax'] as String?,
      (json['registered'] as num?)?.toInt(),
      json['address'] as String?,
      json['province'] as String?,
      json['district'] as String?,
      json['sub_district'] as String?,
      json['postal_code'] as String?,
      json['authorized_person'] as String?,
      json['authorized_person_phone'] as String?,
      json['authorized_person_email'] as String?,
      json['id_card_picture'] as String?,
      json['certificate_book_file'] as String?,
      json['tax_book_file'] as String?,
      json['logo_file'] as String?,
      (json['member_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RegisterImporterToJson(RegisterImporter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'comp_name': instance.comp_name,
      'comp_tax': instance.comp_tax,
      'registered': instance.registered,
      'address': instance.address,
      'province': instance.province,
      'district': instance.district,
      'sub_district': instance.sub_district,
      'postal_code': instance.postal_code,
      'authorized_person': instance.authorized_person,
      'authorized_person_phone': instance.authorized_person_phone,
      'authorized_person_email': instance.authorized_person_email,
      'id_card_picture': instance.id_card_picture,
      'certificate_book_file': instance.certificate_book_file,
      'tax_book_file': instance.tax_book_file,
      'logo_file': instance.logo_file,
      'member_id': instance.member_id,
    };
