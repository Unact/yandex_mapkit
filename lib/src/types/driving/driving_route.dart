part of '../../../yandex_mapkit.dart';

/// Driving route.
/// A route consists of multiple sections
/// Each section has a corresponding annotation that describes the action at the beginning of the section.
class DrivingRoute extends Equatable {

  /// Route geometry.
  final Polyline geometry;

  /// The route metadata.
  final DrivingSectionMetadata metadata;

  const DrivingRoute._(this.geometry, this.metadata);

  factory DrivingRoute._fromJson(Map<dynamic, dynamic> json) {
    return DrivingRoute._(
      Polyline._fromJson(json['geometry']),
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
