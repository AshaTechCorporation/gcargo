import 'package:gcargo/models/deliveryorder.dart';
import 'package:gcargo/models/orders/deliveryorderthailists.dart';
import 'package:gcargo/models/producttype.dart';
import 'package:json_annotation/json_annotation.dart';

part 'billlistsgrouped.g.dart';

@JsonSerializable()
class BillListsGrouped {
  int? id;
  String? code;
  String? barcode;
  int? product_draft_id;
  int? delivery_order_id;
  int? delivery_order_tracking_id;
  int? product_type_id;
  String? product_name;
  String? product_image;
  int? standard_size_id;
  String? weight;
  String? width;
  String? height;
  String? long;
  int? qty;
  int? qty_box;
  int? pallet_id;
  int? sack_id;
  int? packing_list_id;
  String? submit_account_system;
  String? state;
  DateTime? created_at;
  DateTime? updated_at;
  ProductType? product_type;
  List<DeliveryOrderThailists>? delivery_order_thai_lists;
  DeliveryOrder? delivery_order;

  BillListsGrouped(
    this.id,
    this.code,
    this.barcode,
    this.product_draft_id,
    this.delivery_order_id,
    this.delivery_order_tracking_id,
    this.product_type_id,
    this.product_name,
    this.product_image,
    this.standard_size_id,
    this.weight,
    this.width,
    this.height,
    this.long,
    this.qty,
    this.qty_box,
    this.pallet_id,
    this.sack_id,
    this.packing_list_id,
    this.submit_account_system,
    this.state,
    this.created_at,
    this.updated_at,
    this.product_type,
    this.delivery_order_thai_lists,
    this.delivery_order,
  );

  factory BillListsGrouped.fromJson(Map<String, dynamic> json) => _$BillListsGroupedFromJson(json);

  Map<String, dynamic> toJson() => _$BillListsGroupedToJson(this);
}
