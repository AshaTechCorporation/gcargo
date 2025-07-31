import 'package:gcargo/models/orders/deliveryorderlists.dart';
import 'package:gcargo/models/orders/order.dart';
import 'package:gcargo/models/store.dart';
import 'package:gcargo/models/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deliveryorder.g.dart';

@JsonSerializable()
class DeliveryOrder {
  int? id;
  String? code;
  String? po_no;
  String? member_id;
  int? order_id;
  String? date;
  String? driver_name;
  String? driver_phone;
  String? note;
  String? shipment_by;
  String? shipment_china;
  int? store_id;
  int? member_importer_code_id;
  int? product_type_id;
  String? status;
  Order? order;
  Track? track;
  Store? store;
  List<DeliveryOrderLists>? delivery_order_lists;

  DeliveryOrder(
    this.id,
    this.code,
    this.po_no,
    this.member_id,
    this.order_id,
    this.date,
    this.driver_name,
    this.driver_phone,
    this.note,
    this.shipment_by,
    this.shipment_china,
    this.store_id,
    this.member_importer_code_id,
    this.product_type_id,
    this.status,
    this.order,
    this.track,
    this.store,
    this.delivery_order_lists,
  );

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) => _$DeliveryOrderFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryOrderToJson(this);
}
