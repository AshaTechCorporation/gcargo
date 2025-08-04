import 'package:json_annotation/json_annotation.dart';

part 'optionsItem.g.dart';

@JsonSerializable()
class OptionsItem {
  String? option_name;
  String? option_image;
  String? option_note;

  OptionsItem(this.option_name, this.option_image, this.option_note);

  factory OptionsItem.fromJson(Map<String, dynamic> json) => _$OptionsItemFromJson(json);

  Map<String, dynamic> toJson() => _$OptionsItemToJson(this);
}
