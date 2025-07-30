import 'package:json_annotation/json_annotation.dart';

part 'tegaboutus.g.dart';

@JsonSerializable()
class Tegaboutus {
  final int? id;
  final String? detail;
  final String? title_box;
  final String? body_box;
  final String? footer_box;
  final String? phone;
  final String? email;
  final String? wechat;
  final String? line;
  final String? facebook;
  final String? status;

  Tegaboutus({
    this.id,
    this.detail,
    this.title_box,
    this.body_box,
    this.footer_box,
    this.phone,
    this.email,
    this.wechat,
    this.line,
    this.facebook,
    this.status,
  });

  factory Tegaboutus.fromJson(Map<String, dynamic> json) => _$TegaboutusFromJson(json);

  Map<String, dynamic> toJson() => _$TegaboutusToJson(this);
}
