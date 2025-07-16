import 'package:json_annotation/json_annotation.dart';

part 'categoryfeemaster.g.dart';

@JsonSerializable()
class CategoryFeemaster {
  int? id;
  String? code;
  String? type;
  String? name;

  CategoryFeemaster(this.id, this.code, this.type, this.name);

  factory CategoryFeemaster.fromJson(Map<String, dynamic> json) => _$CategoryFeemasterFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryFeemasterToJson(this);
}
