import 'package:gcargo/models/optionsItem.dart';
import 'package:gcargo/models/partService.dart';
import 'package:json_annotation/json_annotation.dart';

part 'products.g.dart';

@JsonSerializable()
class Products {
  String? product_shop;
  String? product_code;
  String? product_name;
  String? product_url;
  String? product_image;
  String? product_category;
  String? product_store_type;
  String? product_note;
  String? product_price;
  String? product_qty;
  List<PartService>? add_on_services;
  List<OptionsItem>? options;

  Products(
    this.product_shop,
    this.product_code,
    this.product_name,
    this.product_url,
    this.product_image,
    this.product_category,
    this.product_store_type,
    this.product_note,
    this.product_price,
    this.product_qty,
    this.add_on_services,
    this.options,
  );

  factory Products.fromJson(Map<String, dynamic> json) => _$ProductsFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsToJson(this);
}
