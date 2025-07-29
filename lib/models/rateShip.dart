import 'package:json_annotation/json_annotation.dart';

part 'rateShip.g.dart';

@JsonSerializable()
class RateShip {
  int? id;
  String? code;
  String? vehicle;
  String? type;
  String? name;
  String? option;
  String? kg;
  String? cbm;
  String? status;

  RateShip(this.id, this.code, this.vehicle, this.type, this.name, this.option, this.kg, this.cbm, this.status);

  factory RateShip.fromJson(Map<String, dynamic> json) => _$RateShipFromJson(json);

  Map<String, dynamic> toJson() => _$RateShipToJson(this);
}
