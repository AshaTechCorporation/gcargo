// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Provice _$ProviceFromJson(Map<String, dynamic> json) => Provice(
      (json['id'] as num?)?.toInt(),
      (json['provinceCode'] as num?)?.toInt(),
      (json['districtCode'] as num?)?.toInt(),
      (json['subdistrictCode'] as num?)?.toInt(),
      json['nameEn'] as String?,
      json['nameTH'] as String?,
      (json['postalCode'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProviceToJson(Provice instance) => <String, dynamic>{
      'id': instance.id,
      'provinceCode': instance.provinceCode,
      'districtCode': instance.districtCode,
      'subdistrictCode': instance.subdistrictCode,
      'nameEn': instance.nameEn,
      'nameTH': instance.nameTH,
      'postalCode': instance.postalCode,
    };
