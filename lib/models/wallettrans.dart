import 'package:gcargo/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallettrans.g.dart';

@JsonSerializable()
class WalletTrans {
  int? id;
  String? code;
  int? member_id;
  String? in_from;
  String? out_to;
  String? reference_id;
  String? detail;
  String? amount;
  String? type;
  String? status;
  DateTime? created_at;
  DateTime? updated_at;
  int? No;
  User? member;

  WalletTrans(
    this.id,
    this.code,
    this.No,
    this.amount,
    this.created_at,
    this.detail,
    this.in_from,
    this.member_id,
    this.out_to,
    this.reference_id,
    this.status,
    this.type,
    this.updated_at,
    this.member,
  );

  factory WalletTrans.fromJson(Map<String, dynamic> json) => _$WalletTransFromJson(json);

  Map<String, dynamic> toJson() => _$WalletTransToJson(this);
}
