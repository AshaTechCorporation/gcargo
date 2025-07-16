import 'package:json_annotation/json_annotation.dart';

part 'optionsOrdersTeack.g.dart';

@JsonSerializable()
class OptionsOrdersTeack {
  int? id;
  int? order_id;
  int? order_list_id;
  String? option_name;
  String? option_image;
  String? option_note;

  OptionsOrdersTeack(this.id, this.order_id, this.order_list_id, this.option_name, this.option_image, this.option_note);

  factory OptionsOrdersTeack.fromJson(Map<String, dynamic> json) => _$OptionsOrdersTeackFromJson(json);

  Map<String, dynamic> toJson() => _$OptionsOrdersTeackToJson(this);
}
