import 'package:json_annotation/json_annotation.dart';

part 'store.g.dart';

@JsonSerializable()
class Store {
  int? id;
  String? code;
  String? name;
  String? name_ch;
  String? name_en;
  String? description;
  String? image;
  String? address;
  String? address_ch;
  String? address_en;
  String? phone;
  String? map;
  String? type;
  String? status;

  Store(
    this.id,
    this.code,
    this.name,
    this.name_ch,
    this.name_en,
    this.description,
    this.image,
    this.address,
    this.address_ch,
    this.address_en,
    this.phone,
    this.map,
    this.type,
    this.status,
  );

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  Map<String, dynamic> toJson() => _$StoreToJson(this);
}
