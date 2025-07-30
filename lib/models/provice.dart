import 'package:json_annotation/json_annotation.dart';

part 'provice.g.dart';

@JsonSerializable()
class Provice {
  int? id;
  int? provinceCode;
  int? districtCode;
  int? subdistrictCode;
  String? nameEn;
  String? nameTH;
  int? postalCode;

  Provice(this.id, this.provinceCode, this.districtCode, this.subdistrictCode, this.nameEn, this.nameTH, this.postalCode);

  factory Provice.fromJson(Map<String, dynamic> json) => _$ProviceFromJson(json);

  Map<String, dynamic> toJson() => _$ProviceToJson(this);
}
