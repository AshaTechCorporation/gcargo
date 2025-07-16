import 'package:gcargo/models/deliveryorder.dart';
import 'package:gcargo/models/importorderlists.dart';
import 'package:gcargo/models/importproductorderlistfees.dart';
import 'package:gcargo/models/orders/deliveryorderlists.dart';
import 'package:gcargo/models/orders/deliveryordertracks.dart';
import 'package:gcargo/models/registerimporter.dart';
import 'package:gcargo/models/store.dart';
import 'package:gcargo/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'importorders.g.dart';

@JsonSerializable()
class Importorders {
  int? id;
  String? code;
  int? member_id;
  int? delivery_order_id;
  int? import_po_id;
  int? register_importer_id;
  int? store_id;
  String? note;
  String? status;
  String? invoice_file;
  String? packinglist_file;
  String? license_file;
  String? total_expenses;
  String? file;
  String? draft_file;
  User? member;
  List<ImportOrderLists>? import_order_lists;
  DateTime? created_at;
  DateTime? updated_at;
  DeliveryOrder? delivery_order;
  List<DeliveryOrderTracks>? delivery_order_tracks;
  List<DeliveryOrderLists>? deliverty_order_lists;
  List<ImportProductOrderlistFees>? import_product_order_list_fees;
  Store? store;
  RegisterImporter? register_importer;

  Importorders(
    this.id,
    this.code,
    this.member_id,
    this.delivery_order_id,
    this.import_po_id,
    this.register_importer_id,
    this.store_id,
    this.note,
    this.status,
    this.invoice_file,
    this.packinglist_file,
    this.license_file,
    this.total_expenses,
    this.file,
    this.draft_file,
    this.member,
    this.import_order_lists,
    this.created_at,
    this.updated_at,
    this.delivery_order,
    this.delivery_order_tracks,
    this.deliverty_order_lists,
    this.import_product_order_list_fees,
    this.store,
    this.register_importer,
  );

  factory Importorders.fromJson(Map<String, dynamic> json) => _$ImportordersFromJson(json);

  Map<String, dynamic> toJson() => _$ImportordersToJson(this);
}
