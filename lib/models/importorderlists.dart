import 'package:json_annotation/json_annotation.dart';

part 'importorderlists.g.dart';

@JsonSerializable()
class ImportOrderLists {
  int? id;
  int? import_product_order_id;
  int? product_type_id;
  String? product_name;
  String? product_image;
  int? standard_size_id;
  int? delivery_order_tracking_id;
  String? weight;
  String? width;
  String? height;
  String? long;
  int? qty;
  int? qty_box;

  ImportOrderLists(
    this.id,
    this.import_product_order_id,
    this.product_type_id,
    this.product_name,
    this.product_image,
    this.standard_size_id,
    this.delivery_order_tracking_id,
    this.weight,
    this.width,
    this.height,
    this.long,
    this.qty,
    this.qty_box,
  );

  factory ImportOrderLists.fromJson(Map<String, dynamic> json) => _$ImportOrderListsFromJson(json);

  Map<String, dynamic> toJson() => _$ImportOrderListsToJson(this);
}
