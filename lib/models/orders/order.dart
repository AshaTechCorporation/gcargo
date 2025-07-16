import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  int? id;
  String? code;
  int? member_id;
  int? member_address_id;
  String? shipping_type;
  String? payment_term;
  String? date;
  String? total_price;
  String? note;
  String? status;

  Order(
    this.id,
    this.code,
    this.member_id,
    this.member_address_id,
    this.shipping_type,
    this.payment_term,
    this.date,
    this.total_price,
    this.note,
    this.status,
  );

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
