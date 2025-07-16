import 'package:gcargo/models/orders/serviceTransporterById.dart';
import 'package:json_annotation/json_annotation.dart';

part 'partAddOnTrack.g.dart';

@JsonSerializable()
class PartAddOnTrack {
  int? id;
  int? order_id;
  int? order_list_id;
  int? add_on_service_id;
  int? add_on_service_price;
  ServiceTransporterById? add_on_service;

  PartAddOnTrack(this.id, this.order_id, this.order_list_id, this.add_on_service_id, this.add_on_service_price, this.add_on_service);

  factory PartAddOnTrack.fromJson(Map<String, dynamic> json) => _$PartAddOnTrackFromJson(json);

  Map<String, dynamic> toJson() => _$PartAddOnTrackToJson(this);
}
