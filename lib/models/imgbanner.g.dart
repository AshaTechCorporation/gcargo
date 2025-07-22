// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imgbanner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImgBanner _$ImgBannerFromJson(Map<String, dynamic> json) => ImgBanner(
  (json['id'] as num?)?.toInt(),
  json['type'] as String?,
  json['image'] as String?,
  (json['seq'] as num?)?.toInt(),
);

Map<String, dynamic> _$ImgBannerToJson(ImgBanner instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'image': instance.image,
  'seq': instance.seq,
};
