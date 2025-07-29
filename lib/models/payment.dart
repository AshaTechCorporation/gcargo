import 'package:gcargo/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  int? id;
  String? code;
  int? member_id;
  String? transaction;
  String? amount;
  String? fee;
  String? image_qr_code;
  String? image;
  String? image_url;
  String? image_slip;
  String? image_slip_url;
  String? phone;
  String? note;
  String? status;
  DateTime? transfer_at;
  DateTime? created_at;
  DateTime? updated_at;
  int? No;
  User? member;

  Payment(
    this.id,
    this.code,
    this.member_id,
    this.transaction,
    this.amount,
    this.fee,
    this.image_qr_code,
    this.image,
    this.image_url,
    this.image_slip,
    this.image_slip_url,
    this.phone,
    this.note,
    this.status,
    this.transfer_at,
    this.created_at,
    this.updated_at,
    this.No,
    this.member,
  );

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
