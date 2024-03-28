part of '../../../yandex_mapkit.dart';

/// Pedestrian route.
/// A route consists of multiple sections
/// Each section has a corresponding annotation that describes the action at the beginning of the section.
class PedestrianRoute extends Equatable {

  /// Route geometry.
  final List<Point> geometry;

  /// The route metadata.
  final PedestrianMetadata metadata;

  const PedestrianRoute._(this.geometry, this.metadata);

  factory PedestrianRoute._fromJson(Map<dynamic, dynamic> json) {
    return PedestrianRoute._(
      Polyline._fromJson(json['polyline']).points,
      PedestrianMetadata._fromJson(json['metadata'])
    );
  }

  @override
  List<Object> get props => <Object>[
    geometry,
    metadata
  ];

  @override
  bool get stringify => true;
}
