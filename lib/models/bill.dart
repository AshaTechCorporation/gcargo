import 'package:gcargo/models/billlistsgrouped.dart';
import 'package:gcargo/models/memberaddress.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bill.g.dart';

@JsonSerializable()
class Bill {
  int? id;
  String? code;
  String? in_thai_date;
  int? member_id;
  int? member_address_id;
  String? total_amount;
  String? total_vat;
  String? notes;
  String? status;
  DateTime? created_at;
  DateTime? updated_at;
  MemberAddress? member_address;
  List<BillListsGrouped>? bill_lists_grouped;

  Bill(
    this.id,
    this.code,
    this.in_thai_date,
    this.member_id,
    this.member_address_id,
    this.total_amount,
    this.total_vat,
    this.notes,
    this.status,
    this.created_at,
    this.updated_at,
    this.member_address,
    this.bill_lists_grouped,
  );

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);

  Map<String, dynamic> toJson() => _$BillToJson(this);
}
