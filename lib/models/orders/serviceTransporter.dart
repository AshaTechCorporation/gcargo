import 'package:gcargo/models/orders/serviceTransporterById.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serviceTransporter.g.dart';

@JsonSerializable()
class ServiceTransporter {
  int? id;
  String? code;
  String? name;
  String? description;
  String? image;
  String? type;
  String? remark;
  String? line;
  String? phone;
  String? address;
  String? prefix;
  String? taobao;
  String? one_six_eight_eight;
  // String? status;
  List<ServiceTransporterById>? images;
  List<ServiceTransporterById>? icons;
  List<ServiceTransporterById>? icon_boxs;
  String? icon;
  String? url;
  bool checkClose;

  ServiceTransporter(
    this.id,
    this.code,
    this.name,
    this.description,
    this.image,
    this.type,
    this.remark,
    this.line,
    this.phone,
    this.address,
    // this.status,
    this.images,
    this.icons,
    this.icon_boxs,
    this.one_six_eight_eight,
    this.prefix,
    this.taobao,
    this.icon,
    this.url, {
    this.checkClose = false,
  });

  factory ServiceTransporter.fromJson(Map<String, dynamic> json) => _$ServiceTransporterFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceTransporterToJson(this);
}
