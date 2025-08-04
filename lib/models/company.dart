import 'package:json_annotation/json_annotation.dart';

part 'company.g.dart';

@JsonSerializable()
class Company {
  int? id;
  String? code;
  int? member_id;
  String? comp_name;
  String? comp_tax;
  int? registered;
  String? comp_phone;
  String? address;
  String? cargo_website;
  String? cargo_image;
  int? transport_thai_master_id;
  String? province;
  String? district;
  String? sub_district;
  String? postal_code;
  String? latitude;
  String? longitude;
  String? transport_type;
  String? order_quantity_in_thai;
  String? order_quantity;
  String? have_any_customers;
  String? additional_requests;
  String? frequent_importer;

  Company(
    this.id,
    this.code,
    this.member_id,
    this.comp_name,
    this.comp_tax,
    this.comp_phone,
    this.cargo_website,
    this.cargo_image,
    this.transport_thai_master_id,
    this.province,
    this.district,
    this.sub_district,
    this.postal_code,
    this.latitude,
    this.longitude,
    this.transport_type,
    this.order_quantity_in_thai,
    this.order_quantity,
    this.have_any_customers,
    this.additional_requests,
    this.address,
    this.registered,
    this.frequent_importer,
  );

  factory Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}
