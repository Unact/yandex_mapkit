part of '../../yandex_mapkit.dart';

/// Masstransit route.
/// A route consists of multiple sections
/// Each section has a corresponding annotation that describes the action at the beginning of the section.
class MasstransitRoute extends Equatable {

  /// Route geometry.
  final Polyline geometry;

  /// The route metadata.
  final MasstransitMetadata metadata;

  const MasstransitRoute._(this.geometry, this.metadata);

  factory MasstransitRoute._fromJson(Map<dynamic, dynamic> json) {
    return MasstransitRoute._(
      Polyline._fromJson(json['geometry']),
      MasstransitMetadata._fromJson(json['metadata'])
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
