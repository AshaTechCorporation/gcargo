import 'package:gcargo/models/orders/deliveryorderlists.dart';
import 'package:gcargo/models/orders/order.dart';
import 'package:gcargo/models/track.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deliveryorder.g.dart';

@JsonSerializable()
class DeliveryOrder {
  int? id;
  String? code;
  String? member_id;
  int? order_id;
  String? date;
  String? driver_name;
  String? driver_phone;
  String? note;
  String? status;
  Order? order;
  Track? track;
  List<DeliveryOrderLists>? delivery_order_lists;

  DeliveryOrder(
    this.id,
    this.code,
    this.member_id,
    this.order_id,
    this.date,
    this.driver_name,
    this.driver_phone,
    this.note,
    this.status,
    this.order,
    this.track,
    this.delivery_order_lists,
  );

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) => _$DeliveryOrderFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryOrderToJson(this);
}
