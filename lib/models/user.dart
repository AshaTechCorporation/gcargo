import 'package:gcargo/models/company.dart';
import 'package:gcargo/models/memberbank.dart';
import 'package:gcargo/models/shipping.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int? id;
  String? code;
  String? member_type;
  String? fname;
  String? lname;
  String? phone;
  String? birth_date;
  String? gender;
  String? importer_code;
  String? password;
  String? referrer;
  String? address;
  String? province;
  String? district;
  String? sub_district;
  String? postal_code;
  String? wallet_balance;
  String? point_balance;
  String? image;
  String? avaliable_time;
  String? credit_limit;
  String? loan_amount;
  String? bus_route;
  String? email;
  String? facebook;
  String? line_id;
  String? wechat;
  int? notify_sms;
  int? notify_line;
  int? notify_email;
  int? transport_rate_id;
  String? found_via;
  int? priority_update_tracking;
  int? priority_package_protection;
  int? priority_order_system;
  String? responsible_person;
  String? responsible_sale;
  String? responsible_remark;
  String? id_card_copy;
  String? company_certificate;
  String? pp20_document;
  String? language;
  Company? detail;
  List<Shipping>? ship_address;
  List<MemberBank>? member_banks;

  User(
    this.id,
    this.code,
    this.member_type,
    this.fname,
    this.lname,
    this.phone,
    this.birth_date,
    this.gender,
    this.importer_code,
    this.password,
    this.referrer,
    this.address,
    this.province,
    this.district,
    this.sub_district,
    this.postal_code,
    this.wallet_balance,
    this.point_balance,
    this.image,
    this.avaliable_time,
    this.credit_limit,
    this.loan_amount,
    this.bus_route,
    this.email,
    this.facebook,
    this.line_id,
    this.wechat,
    this.notify_sms,
    this.notify_line,
    this.notify_email,
    this.found_via,
    this.priority_update_tracking,
    this.priority_package_protection,
    this.priority_order_system,
    this.responsible_person,
    this.responsible_sale,
    this.responsible_remark,
    this.id_card_copy,
    this.company_certificate,
    this.pp20_document,
    this.language,
    this.detail,
    this.ship_address,
    this.member_banks,
    this.transport_rate_id,
  );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
