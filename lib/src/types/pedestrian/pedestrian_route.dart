part of '../../../yandex_mapkit.dart';

/// Pedestrian route.
/// A route consists of multiple sections
/// Each section has a corresponding annotation that describes the action at the beginning of the section.
class PedestrianRoute extends Equatable {

  /// Route geometry.
  final Polyline geometry;

  /// The route metadata.
  final PedestrianMetadata metadata;

  const PedestrianRoute._(this.geometry, this.metadata);

  factory PedestrianRoute._fromJson(Map<dynamic, dynamic> json) {
    return PedestrianRoute._(
      Polyline._fromJson(json['geometry']),
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
