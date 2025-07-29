import 'package:json_annotation/json_annotation.dart';

part 'transferFee.g.dart';

@JsonSerializable()
class TransferFee {
  int? id;
  String? transfer_fee;
  String? alipay_fee;
  String? account_open_fee;

  TransferFee(this.id, this.transfer_fee, this.alipay_fee, this.account_open_fee);

  factory TransferFee.fromJson(Map<String, dynamic> json) => _$TransferFeeFromJson(json);

  Map<String, dynamic> toJson() => _$TransferFeeToJson(this);
}
