import 'package:gcargo/models/memberaddress.dart';
import 'package:json_annotation/json_annotation.dart';

part 'producttype.g.dart';

@JsonSerializable()
class ProductType {
  int? id;
  String? code;
  String? name;
  String? description;
  String? status;
  DateTime? created_at;
  DateTime? updated_at;

  ProductType(this.id, this.code, this.name, this.description, this.status, this.created_at, this.updated_at);

  factory ProductType.fromJson(Map<String, dynamic> json) => _$ProductTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ProductTypeToJson(this);
}
