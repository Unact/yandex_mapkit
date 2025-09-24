part of '../../yandex_mapkit.dart';

/// Point for a route build request
///
/// There are two types of request points.
///
/// A waypoint is a destination. Use it when you plan to stop there.
/// Via points (throughpoints) correct the route to make it pass through all the via points.
///
/// Waypoints are guaranteed to be between sections in the resulting route.
/// Via points are embedded into sections.
class RequestPoint extends Equatable {

  /// The request point.
  final Point point;

  /// The type of request point specified.
  final RequestPointType requestPointType;

  ///  Opaque string that describe entrances, driving arrival points and so on.
  final String? pointContext;

  /// Specifies what driving arrival point to use. If point is not specified then server will select one.
  final String? drivingArrivalPointId;

  /// Indoor level (floor) id
  final String? indoorLevelId;

  const RequestPoint({
    required this.point,
    required this.requestPointType,
    this.pointContext,
    this.drivingArrivalPointId,
    this.indoorLevelId,
  });

  @override
  List<Object?> get props => <Object?>[
    point,
    requestPointType,
    pointContext,
    drivingArrivalPointId,
    indoorLevelId
  ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'requestPointType': requestPointType.value,
      'point': point.toJson(),
      'pointContext': pointContext,
      'drivingArrivalPointId': drivingArrivalPointId,
      'indoorLevelId': indoorLevelId,
    };
  }
}

/// The waypoint and a point the path must go through.
enum RequestPointType {
  wayPoint,
  viaPoint
}

extension RequestPointTypeExtension on RequestPointType {
  int get value {
    switch (this) {
      case RequestPointType.wayPoint:
        return 0;
      case RequestPointType.viaPoint:
        return 1;
    }
  }
}
