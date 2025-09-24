part of '../../yandex_mapkit.dart';

/// Information about driving route metadata.
class MasstransitTravelEstimation extends Equatable {

  /// Departure time for a masstransit route
  final DateTime departureTime;

  /// Departure time for a masstransit route
  final DateTime arrivalTime;

  const MasstransitTravelEstimation._(this.departureTime, this.arrivalTime);

  factory MasstransitTravelEstimation._fromJson(Map<dynamic, dynamic> json) {
    return MasstransitTravelEstimation._(
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
