import 'package:json_annotation/json_annotation.dart';

part 'imgbanner.g.dart';

@JsonSerializable()
class ImgBanner {
  int? id;
  String? type;
  String? image;
  int? seq;

  ImgBanner(this.id, this.type, this.image, this.seq);

  factory ImgBanner.fromJson(Map<String, dynamic> json) => _$ImgBannerFromJson(json);

  Map<String, dynamic> toJson() => _$ImgBannerToJson(this);
}
