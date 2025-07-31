import 'package:json_annotation/json_annotation.dart';

part 'memberaddress.g.dart';

@JsonSerializable()
class MemberAddress {
  int? id;
  String? code;
  int? member_id;
  String? address;
  String? province;
  String? district;
  String? sub_district;
  String? postal_code;
  String? latitude;
  String? longitude;
  String? contact_name;
  String? contact_phone;
  String? contact_phone2;
  String? status;
  String? first;
  DateTime? created_at;
  DateTime? updated_at;

  MemberAddress(
    this.id,
    this.code,
    this.member_id,
    this.address,
    this.province,
    this.district,
    this.sub_district,
    this.postal_code,
    this.latitude,
    this.longitude,
    this.contact_name,
    this.contact_phone,
    this.contact_phone2,
    this.status,
    this.first,
    this.created_at,
    this.updated_at,
  );

  factory MemberAddress.fromJson(Map<String, dynamic> json) => _$MemberAddressFromJson(json);

  Map<String, dynamic> toJson() => _$MemberAddressToJson(this);
}
