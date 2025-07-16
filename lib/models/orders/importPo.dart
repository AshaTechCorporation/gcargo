import 'package:json_annotation/json_annotation.dart';

part 'importPo.g.dart';

@JsonSerializable()
class ImportPo {
  int? id;
  int? member_id;
  int? delivery_order_id;
  String? status;
  DateTime? created_at;
  DateTime? updated_at;

  ImportPo(this.created_at, this.updated_at, this.id, this.member_id, this.delivery_order_id, this.status);

  factory ImportPo.fromJson(Map<String, dynamic> json) => _$ImportPoFromJson(json);

  Map<String, dynamic> toJson() => _$ImportPoToJson(this);
}
