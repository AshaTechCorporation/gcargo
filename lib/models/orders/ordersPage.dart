import 'package:gcargo/models/orders/deliveryorderlists.dart';
import 'package:gcargo/models/orders/ordersPageNew.dart';
import 'package:gcargo/models/orders/productsTrack.dart';
import 'package:gcargo/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ordersPage.g.dart';

@JsonSerializable()
class OrdersPage {
  int? id;
  String? code;
  String? date;
  String? shipping_type;
  String? total_price;
  int? member_id;
  String? payment_term;
  String? note;
  int? member_address_id;
  String? status;
  String? deposit_fee;
  String? exchange_rate;
  String? china_shipping_fee;
  DateTime? created_at;
  User? member;
  List<ProductsTrack>? order_lists;
  List<OrdersPage>? orders;
  List<DeliveryOrderLists>? delivery_order_lists;
  List<OrdersPageNew>? delivery_orders;

  OrdersPage(
    this.date,
    this.total_price,
    this.member_id,
    this.shipping_type,
    this.payment_term,
    this.note,
    this.member_address_id,
    this.status,
    this.deposit_fee,
    this.exchange_rate,
    this.china_shipping_fee,
    this.created_at,
    this.member,
    this.order_lists,
    this.orders,
    this.delivery_order_lists,
    this.code,
    this.id,
    this.delivery_orders,
  );

  factory OrdersPage.fromJson(Map<String, dynamic> json) => _$OrdersPageFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersPageToJson(this);
}
