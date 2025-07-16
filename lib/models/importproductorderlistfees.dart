import 'package:gcargo/models/feemaster.dart';
import 'package:json_annotation/json_annotation.dart';

part 'importproductorderlistfees.g.dart';

@JsonSerializable()
class ImportProductOrderlistFees {
  int? id;
  int? import_product_order_id;
  int? fee_master_id;
  int? amount;
  String? status;
  Feemaster? fee_master;

  ImportProductOrderlistFees(this.id, this.import_product_order_id, this.fee_master_id, this.amount, this.status, this.fee_master);

  factory ImportProductOrderlistFees.fromJson(Map<String, dynamic> json) => _$ImportProductOrderlistFeesFromJson(json);

  Map<String, dynamic> toJson() => _$ImportProductOrderlistFeesToJson(this);
}
