import 'package:gcargo/models/orders/deilvery.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shippingDeilvery.g.dart';

@JsonSerializable()
class ShippingDeilvery {
  int? id;
  int? member_address_id;
  int? member_id;
  String? code;
  String? shipping_type;
  String? payment_term;
  String? date;
  String? status;
  String? total_price;
  String? note;
  String? deposit_fee;
  String? exchange_rate;
  String? china_shipping_fee;
  List<Deilvery>? order_lists;

  ShippingDeilvery(
    this.id,
    this.member_address_id,
    this.member_id,
    this.code,
    this.shipping_type,
    this.payment_term,
    this.date,
    this.status,
    this.total_price,
    this.note,
    this.deposit_fee,
    this.exchange_rate,
    this.china_shipping_fee,
    this.order_lists,
  );

  factory ShippingDeilvery.fromJson(Map<String, dynamic> json) => _$ShippingDeilveryFromJson(json);

  Map<String, dynamic> toJson() => _$ShippingDeilveryToJson(this);
}
