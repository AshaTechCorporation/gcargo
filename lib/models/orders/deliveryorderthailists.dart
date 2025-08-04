import 'package:gcargo/models/memberaddress.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deliveryorderthailists.g.dart';

@JsonSerializable()
class DeliveryOrderThailists {
  int? id;
  int? delivery_order_thai_id;
  int? delivery_order_id;
  int? delivery_order_list_id;
  int? delivery_order_list_item_id;
  int? order_id;
  int? member_id;
  int? member_address_id;
  DateTime? created_at;
  DateTime? updated_at;

  DeliveryOrderThailists(
    this.id,
    this.delivery_order_thai_id,
    this.delivery_order_id,
    this.delivery_order_list_id,
    this.delivery_order_list_item_id,
    this.order_id,
    this.member_id,
    this.member_address_id,
    this.created_at,
    this.updated_at,
  );

  factory DeliveryOrderThailists.fromJson(Map<String, dynamic> json) => _$DeliveryOrderThailistsFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryOrderThailistsToJson(this);
}
