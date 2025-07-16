import 'package:gcargo/models/orders/deliveryorderlists.dart';
import 'package:json_annotation/json_annotation.dart';

part 'openBillById.g.dart';

@JsonSerializable()
class OpenBillById {
  int? id;
  int? billing_id;
  int? delivery_order_thai_list_id;
  int? delivery_order_thai_id;
  String? amount;
  String? status;
  List<DeliveryOrderLists>? delivery_order_list;

  OpenBillById(
    this.id,
    this.billing_id,
    this.delivery_order_thai_list_id,
    this.delivery_order_thai_id,
    this.amount,
    this.status,
    this.delivery_order_list,
  );

  factory OpenBillById.fromJson(Map<String, dynamic> json) => _$OpenBillByIdFromJson(json);

  Map<String, dynamic> toJson() => _$OpenBillByIdToJson(this);
}
