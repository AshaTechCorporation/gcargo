import 'package:json_annotation/json_annotation.dart';

part 'manual.g.dart';

@JsonSerializable()
class Manual {
  int? id;
  String? code;
  int? category_member_manual_id;
  String? name;
  String? description;
  String? image;
  int? No;

  Manual(this.id, this.code, this.category_member_manual_id, this.name, this.description, this.image, this.No);

  factory Manual.fromJson(Map<String, dynamic> json) => _$ManualFromJson(json);

  Map<String, dynamic> toJson() => _$ManualToJson(this);
}
