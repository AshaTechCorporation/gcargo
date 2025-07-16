import 'package:gcargo/models/orders/openBillById.dart';
import 'package:gcargo/models/orders/ordersPageNew.dart';
import 'package:gcargo/models/orders/serviceTransporter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deliveryorderlists.g.dart';

@JsonSerializable()
class DeliveryOrderLists {
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
  List<OpenBillById>? delivery_order_thai_lists;
  OrdersPageNew? delivery_order;
  ServiceTransporter? product_type;
  bool? selected;
  bool? selected2;

  DeliveryOrderLists(
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
    this.delivery_order_thai_lists,
    this.delivery_order,
    this.product_type, {
    this.selected = false,
    this.selected2 = false,
  });

  factory DeliveryOrderLists.fromJson(Map<String, dynamic> json) => _$DeliveryOrderListsFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryOrderListsToJson(this);
}
