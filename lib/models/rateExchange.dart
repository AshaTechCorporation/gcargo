import 'package:json_annotation/json_annotation.dart';

part 'rateExchange.g.dart';

@JsonSerializable()
class RateExchange {
  String? base;
  String? target;
  String? rate;
  DateTime? fetched_at;

  RateExchange(this.base, this.target, this.rate, this.fetched_at);

  factory RateExchange.fromJson(Map<String, dynamic> json) => _$RateExchangeFromJson(json);

  Map<String, dynamic> toJson() => _$RateExchangeToJson(this);
}
