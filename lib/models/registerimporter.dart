import 'package:json_annotation/json_annotation.dart';

part 'registerimporter.g.dart';

@JsonSerializable()
class RegisterImporter {
  int? id;
  String? code;
  String? comp_name;
  String? comp_tax;
  int? registered;
  String? address;
  String? province;
  String? district;
  String? sub_district;
  String? postal_code;
  String? authorized_person;
  String? authorized_person_phone;
  String? authorized_person_email;
  String? id_card_picture;
  String? certificate_book_file;
  String? tax_book_file;
  String? logo_file;
  int? member_id;

  RegisterImporter(
    this.id,
    this.code,
    this.comp_name,
    this.comp_tax,
    this.registered,
    this.address,
    this.province,
    this.district,
    this.sub_district,
    this.postal_code,
    this.authorized_person,
    this.authorized_person_phone,
    this.authorized_person_email,
    this.id_card_picture,
    this.certificate_book_file,
    this.tax_book_file,
    this.logo_file,
    this.member_id,
  );

  factory RegisterImporter.fromJson(Map<String, dynamic> json) => _$RegisterImporterFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterImporterToJson(this);
}
