import 'package:gcargo/models/orders/deliveryorderlists.dart';
import 'package:json_annotation/json_annotation.dart';

part 'track.g.dart';

@JsonSerializable()
class Track {
  int? id;
  int? delivery_order_id;
  int? track_id;
  String? track_no;
  List<DeliveryOrderLists>? delivery_order_lists;

  Track(this.id, this.delivery_order_id, this.track_id, this.track_no, this.delivery_order_lists);

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}
