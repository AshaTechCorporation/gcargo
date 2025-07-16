import 'package:gcargo/models/orders/deliveryorderlists.dart';
import 'package:gcargo/models/orders/importPo.dart';
import 'package:gcargo/models/orders/serviceTransporter.dart';
import 'package:gcargo/models/orders/shippingDeilvery.dart';
import 'package:gcargo/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ordersPageNew.g.dart';

@JsonSerializable()
class OrdersPageNew {
  int? id;
  String? code;
  String? po_no;
  int? order_id;
  String? date;
  String? driver_name;
  String? driver_phone;
  String? member_id;
  String? payment_term;
  String? note;
  String? shipment_by;
  int? member_address_id;
  String? status;
  DateTime? created_at;
  User? member;
  List<DeliveryOrderLists>? delivery_order_lists;
  ServiceTransporter? store;
  ServiceTransporter? product_type;
  ImportPo? import_po;
  ShippingDeilvery? order;

  OrdersPageNew(
    this.date,
    this.member_id,
    this.po_no,
    this.payment_term,
    this.note,
    this.member_address_id,
    this.status,
    this.created_at,
    this.member,
    this.shipment_by,
    this.delivery_order_lists,
    this.code,
    this.id,
    this.order_id,
    this.driver_name,
    this.driver_phone,
    this.store,
    this.product_type,
    this.import_po,
    this.order,
  );

  factory OrdersPageNew.fromJson(Map<String, dynamic> json) => _$OrdersPageNewFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersPageNewToJson(this);
}
