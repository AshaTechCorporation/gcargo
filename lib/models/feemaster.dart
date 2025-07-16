import 'package:gcargo/models/categoryfeemaster.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feemaster.g.dart';

@JsonSerializable()
class Feemaster {
  int? id;
  String? code;
  int? category_fee_master_id;
  String? name;
  int? price;
  String? check;
  CategoryFeemaster? category_fee_master;

  Feemaster(this.id, this.code, this.category_fee_master_id, this.name, this.price, this.check, this.category_fee_master);

  factory Feemaster.fromJson(Map<String, dynamic> json) => _$FeemasterFromJson(json);

  Map<String, dynamic> toJson() => _$FeemasterToJson(this);
}
