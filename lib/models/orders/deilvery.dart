import 'package:json_annotation/json_annotation.dart';

part 'deilvery.g.dart';

@JsonSerializable()
class Deilvery {
  int? id;
  String? track_ecommerce_no;
  int? product_draft_id;
  int? product_type_id;
  String? product_shop;
  String? product_code;
  String? product_name;
  String? product_url;
  String? product_image;
  String? product_category;
  String? product_store_type;
  String? product_price;
  int? product_qty;
  String? product_real_price;
  int? standard_size_id;
  double? weight;
  double? width;
  double? height;
  double? long;
  int? qty;
  int? qty_box;

  Deilvery(
    this.id,
    this.track_ecommerce_no,
    this.product_draft_id,
    this.product_type_id,
    this.product_shop,
    this.product_code,
    this.product_name,
    this.product_url,
    this.product_image,
    this.product_category,
    this.product_price,
    this.product_store_type,
    this.product_qty,
    this.product_real_price,
    this.standard_size_id,
    this.weight,
    this.width,
    this.height,
    this.long,
    this.qty,
    this.qty_box,
  );

  factory Deilvery.fromJson(Map<String, dynamic> json) => _$DeilveryFromJson(json);

  Map<String, dynamic> toJson() => _$DeilveryToJson(this);
}
