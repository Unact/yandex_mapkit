part of yandex_mapkit;

/// Information about pedestrian route metadata.
class PedestrianRouteMetadata extends Equatable {
  /// Route "weight".
  final PedestrianWeight weight;

  const PedestrianRouteMetadata._(this.weight);

  factory PedestrianRouteMetadata._fromJson(Map<dynamic, dynamic> json) {
    return PedestrianRouteMetadata._(
        PedestrianWeight._fromJson(json['weight']));
  }

  @override
  List<Object> get props => <Object>[
        weight,
      ];

  @override
  bool get stringify => true;
}

/// Quantitative characteristics of any segment of the route.
class PedestrianWeight extends Equatable {
  /// Time to travel, not considering traffic.
  final LocalizedValue time;

  /// Distance to travel.
  final LocalizedValue distance;

  const PedestrianWeight._(this.time, this.distance);

  factory PedestrianWeight._fromJson(Map<dynamic, dynamic> json) {
    return PedestrianWeight._(
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
