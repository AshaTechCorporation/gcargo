import 'package:gcargo/models/orders/optionsOrdersTeack.dart';
import 'package:gcargo/models/orders/partAddOnTrack.dart';
import 'package:json_annotation/json_annotation.dart';

part 'productsTrack.g.dart';

@JsonSerializable()
class ProductsTrack {
  String? track_ecommerce_no;
  String? po_no;
  String? product_code;
  String? product_name;
  String? product_url;
  String? product_image;
  String? product_category;
  String? product_store_type;
  String? product_note;
  String? product_price;
  int? product_qty;
  List<PartAddOnTrack>? add_on_services;
  List<OptionsOrdersTeack>? options;

  ProductsTrack(
    this.track_ecommerce_no,
    this.po_no,
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

  factory ProductsTrack.fromJson(Map<String, dynamic> json) => _$ProductsTrackFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsTrackToJson(this);
}
