import 'package:json_annotation/json_annotation.dart';

part 'deliveryordertracks.g.dart';

@JsonSerializable()
class DeliveryOrderTracks {
  int? id;
  int? delivery_order_id;
  int? track_id;
  String? track_no;

  DeliveryOrderTracks(this.id, this.delivery_order_id, this.track_id, this.track_no);

  factory DeliveryOrderTracks.fromJson(Map<String, dynamic> json) => _$DeliveryOrderTracksFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryOrderTracksToJson(this);
}
