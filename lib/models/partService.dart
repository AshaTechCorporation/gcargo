import 'package:json_annotation/json_annotation.dart';

part 'partService.g.dart';

@JsonSerializable()
class PartService {
  int? add_on_service_id;
  int? add_on_service_price;

  PartService(this.add_on_service_id, this.add_on_service_price);

  factory PartService.fromJson(Map<String, dynamic> json) => _$PartServiceFromJson(json);

  Map<String, dynamic> toJson() => _$PartServiceToJson(this);
}
