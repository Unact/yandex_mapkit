part of '../../yandex_mapkit.dart';

/// Information about masstransit route metadata.
class MasstransitMetadata extends Equatable {

  /// Route "weight".
  final MasstransitWeight weight;

  /// Arrival and departure time estimations for time-dependent routes.
  final MasstransitTravelEstimation? estimation;

  const MasstransitMetadata._(this.weight, this.estimation);

  factory MasstransitMetadata._fromJson(Map<dynamic, dynamic> json) {
    return MasstransitMetadata._(
      MasstransitWeight._fromJson(json['weight']),
      json['estimation'] != null ? MasstransitTravelEstimation._fromJson(json['estimation']) : null
    );
  }

  @override
  List<Object?> get props => <Object?>[
    weight,
    estimation
  ];

  @override
  bool get stringify => true;
}

/// Quantitative characteristics of any segment of the route.
class MasstransitWeight extends Equatable {

  /// Time to travel.
  final LocalizedValue time;

  /// The number of transfers for a route or a route section.
  final int transfersCount;

  /// Distance to travel.
  final LocalizedValue walkingDistance;

  const MasstransitWeight._(this.time, this.transfersCount, this.walkingDistance);

  factory MasstransitWeight._fromJson(Map<dynamic, dynamic> json) {
    return MasstransitWeight._(
      LocalizedValue._fromJson(json['time']),
      json['transfersCount'],
      LocalizedValue._fromJson(json['walkingDistance']),
    );
  }

  @override
  List<Object> get props => <Object>[
    time,
    transfersCount,
    walkingDistance,
  ];

  @override
  bool get stringify => true;
}
