import 'package:json_annotation/json_annotation.dart';

part 'serviceTransporterById.g.dart';

@JsonSerializable()
class ServiceTransporterById {
  int? id;
  String? code;
  int? service_id;
  String? name;
  String? description;
  String? image;
  int? standard_price;
  // String? status;

  ServiceTransporterById(
    this.id,
    this.code,
    this.service_id,
    this.name,
    this.description,
    this.image,
    this.standard_price,
    // this.status,
  );

  factory ServiceTransporterById.fromJson(Map<String, dynamic> json) => _$ServiceTransporterByIdFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceTransporterByIdToJson(this);
}
