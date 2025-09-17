import 'package:json_annotation/json_annotation.dart';

part 'memberbank.g.dart';

@JsonSerializable()
class MemberBank {
  int? id;
  String? code;
  int? member_id;
  String? name;
  String? description;
  String? image;
  String? status;
  DateTime? created_at;
  DateTime? updated_at;

  MemberBank(this.id, this.code, this.member_id, this.name, this.description, this.image, this.status, this.created_at, this.updated_at);

  factory MemberBank.fromJson(Map<String, dynamic> json) => _$MemberBankFromJson(json);

  Map<String, dynamic> toJson() => _$MemberBankToJson(this);
}
