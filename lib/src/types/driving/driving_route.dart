part of yandex_mapkit;

/// Driving route.
/// A route consists of multiple sections
/// Each section has a corresponding annotation that describes the action at the beginning of the section.
class DrivingRoute extends Equatable {
  /// Route geometry.
  final List<Point> geometry;

  /// The route metadata.
  final DrivingSectionMetadata metadata;

  const DrivingRoute._(this.geometry, this.metadata);

  factory DrivingRoute._fromJson(Map<dynamic, dynamic> json) {
    return DrivingRoute._(
      Polyline._fromJson(json['polyline']).points,
      DrivingSectionMetadata._fromJson(json['metadata']),
    );
  }

  @override
  List<Object> get props => <Object>[
        geometry,
        metadata,
      ];

  @override
  bool get stringify => true;
}
