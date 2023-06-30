part of yandex_mapkit;

/// Quantitative characteristics of any segment of the route.
class BicycleWeight extends Equatable {

  /// Time to travel, not considering traffic.
  final LocalizedValue time;

  /// Distance to travel.
  final LocalizedValue distance;

  const BicycleWeight._(this.time, this.distance);

  factory BicycleWeight._fromJson(Map<dynamic, dynamic> json) {
    return BicycleWeight._(
      LocalizedValue._fromJson(json['time']),
      LocalizedValue._fromJson(json['distance']),
    );
  }

  @override
  List<Object> get props => <Object>[
    time,
    distance,
  ];

  @override
  bool get stringify => true;
}
