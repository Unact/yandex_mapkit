part of '../../../yandex_mapkit.dart';

/// Information about driving route metadata.
class PedestrianTravelEstimation extends Equatable {

  /// Departure time for a pedestrian route
  final DateTime departureTime;

  /// Departure time for a pedestrian route
  final DateTime arrivalTime;

  const PedestrianTravelEstimation._(this.departureTime, this.arrivalTime);

  factory PedestrianTravelEstimation._fromJson(Map<dynamic, dynamic> json) {
    return PedestrianTravelEstimation._(
      DateTime.fromMillisecondsSinceEpoch(json['departureTime']),
      DateTime.fromMillisecondsSinceEpoch(json['arrivalTime'])
    );
  }

  @override
  List<Object> get props => <Object>[
    departureTime,
    arrivalTime
  ];

  @override
  bool get stringify => true;
}
