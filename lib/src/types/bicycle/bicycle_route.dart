part of '../../../yandex_mapkit.dart';

/// Driving route.
/// A route consists of multiple sections
/// Each section has a corresponding annotation that describes the action at the beginning of the section.
class BicycleRoute extends Equatable {

  /// Route geometry.
  final Polyline geometry;

  /// The route metadata.
  final BicycleWeight weight;

  const BicycleRoute._(this.geometry, this.weight);

  factory BicycleRoute._fromJson(Map<dynamic, dynamic> json) {
    return BicycleRoute._(
      Polyline._fromJson(json['geometry']),
      BicycleWeight._fromJson(json['weight']),
    );
  }

  @override
  List<Object> get props => <Object>[
    geometry,
    weight,
  ];

  @override
  bool get stringify => true;
}
