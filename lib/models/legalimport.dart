import 'package:gcargo/models/importorders.dart';
import 'package:gcargo/models/orders/ordersPageNew.dart';
import 'package:json_annotation/json_annotation.dart';

part 'legalimport.g.dart';

@JsonSerializable()
class LegalImport {
  String? status;
  List<OrdersPageNew>? delivery_orders;
  List<Importorders>? import_orders;

  LegalImport(this.delivery_orders, this.status, this.import_orders);

  factory LegalImport.fromJson(Map<String, dynamic> json) => _$LegalImportFromJson(json);

  Map<String, dynamic> toJson() => _$LegalImportToJson(this);
}
